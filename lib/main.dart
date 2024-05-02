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

  void _showSnackBarAjoutFilm() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Film ajouté à votre liste !'),
      duration: Duration(seconds: 2), // Durée de la notification
    ));
  }

  void _showSnackBarSupprFilm() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Film retiré de votre liste !'),
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
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () {
                // Action pour gérer le bouton "favorite"
              },
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
                onTap: () => _toggleFullScreen(movie),
                child: Card(
                  color: Colors.grey[800],
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
                        child: Text(
                          movie.title,
                          // Titre du film à afficher
                          style: TextStyle(color: Colors.white),
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
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500/${_selectedMovie!.posterPath}',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Movie {
  final int id;
  final String title;
  final String posterPath;

  Movie({required this.id, required this.title, required this.posterPath});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
    );
  }
}
