import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes films',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: ListeFilms(),
    );
  }
}

class ListeFilms extends StatefulWidget {
  @override
  _EtatListeFilms createState() => _EtatListeFilms(); // Pour gérer l'état de la liste de films
}

class _EtatListeFilms extends State<ListeFilms> {
  // Liste pour stocker les films récupérés
  List<Movie> _movies = [];
  bool _isFullScreen = false;
  Movie? _selectedMovie;
  FilmsFavoris _favoris = FilmsFavoris();

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  void fetchMovies() async {
    // Fonction pour récupérer les films depuis l'API
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=d05dd3724e636dc8ca314664f17e1227'));
    if (response.statusCode == 200) {
      // Vérifie si la requête est OK
      final parsed = json.decode(response.body);
      setState(() {
        _movies = List<Movie>.from(parsed['results']
            .map((json) => Movie.fromJson(json))); // Affiche les films si pas d'erreur
      });
    } else {
      throw Exception(
          "OUPS ! Il semblerait qu'il y ait une erreur..."); // Affiche un message d'erreur
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2), // Durée de la notification
    ));
  }

  void _toggleFullScreen(Movie movie) {
    setState(() {
      if (_isFullScreen) {
        _isFullScreen = false;
        _selectedMovie = null;
      } else {
        _isFullScreen = true;
        _selectedMovie = movie;
      }
    });
  }

  void _toggleFavorite(Movie movie) {
    setState(() {
      if (_favoris.contient(movie)) {
        _favoris.retirer(movie);
        _showSnackBar("Le film a été retiré des favoris");
      } else {
        _favoris.ajouter(movie);
        _showSnackBar("Le film a été ajouté aux favoris");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Films à la une :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    // Action pour gérer le bouton "favorite"
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Nombre de films likés'),
                          content: Text(
                              'Vous avez liké ${_favoris.length()} films.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Fermer'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FilmsLikes(favoris: _favoris)));
                              },
                              child: Text('Voir mes films likés'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  right: -3,
                  top: 5,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.yellow,
                    child: Text(
                      '${_favoris.length()}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            // Liste avec colonnes
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // Définit les colonnes
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              return GestureDetector(
                onTap: () {
                  _toggleFullScreen(movie);
                },
                child: Card(
                  color: _favoris.contient(movie)
                      ? Colors.grey[800] // Si liké, fond gris
                      : Colors.grey[900], // Fond gris foncé
                  borderOnForeground: true,
                  shape: _favoris.contient(movie)
                      ? RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0), // Ajout du radius
                  )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        // Image du film
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                          // URL de l'image du film.
                          fit: BoxFit.cover,
                          // Ajuste l'image pour couvrir toute la zone
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        // Définit l'espacement de tous les côtés
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tooltip(
                              message: movie.title,
                              child: Text(
                                _truncateText(movie.title, 15),
                                // Afficher seulement 20 caractères pour eviter l'erreur avec le banner noir & jaune
                                style: TextStyle(
                                  color: _favoris.contient(movie)
                                      ? Colors.white
                                      : Colors.white,
                                  backgroundColor: _favoris.contient(movie)
                                      ? Colors.grey[800]
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: _favoris.contient(movie)
                                  ? Icon(Icons.favorite)
                                  : Icon(Icons.favorite_border),
                              color: _favoris.contient(movie)
                                  ? Colors.red
                                  : Colors.white,
                              onPressed: () {
                                _toggleFavorite(movie);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isFullScreen && _selectedMovie != null)
            GestureDetector(
              onTap: () => _toggleFullScreen(_selectedMovie!),
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500/${_selectedMovie!.posterPath}',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _selectedMovie!.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Date de sortie: ${_selectedMovie!.releaseDate}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
  }
}

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      releaseDate: json['release_date'],
    );
  }
}

class FilmsFavoris {
  List<Movie> _favoris = [];

  void ajouter(Movie movie) {
    _favoris.add(movie);
  }

  void retirer(Movie movie) {
    _favoris.remove(movie);
  }

  bool contient(Movie movie) {
    return _favoris.contains(movie);
  }

  int length() {
    return _favoris.length;
  }
}

class FilmsLikes extends StatelessWidget {
  final FilmsFavoris favoris;

  const FilmsLikes({Key? key, required this.favoris}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes films likés'),
      ),
      body: ListView.builder(
        itemCount: favoris.length(),
        itemBuilder: (context, index) {
          final movie = favoris._favoris[index];
          return ListTile(
            title: Text(movie.title),
            subtitle: Text('Date de sortie: ${movie.releaseDate}'),
            leading: Image.network(
              'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
