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
  _etatlistefilms createState() => _etatlistefilms(); // Pour gerer etat MovieList
}

class _etatlistefilms extends State<ListeFilms> { // Liste pour stocker les films recuperes
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  void fetchMovies() async { // RecupereFilms pour récupérer les films depuis l'API
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=d05dd3724e636dc8ca314664f17e1227'));
    if (response.statusCode == 200) { // Vérifie si requête → OK
      final parsed = json.decode(response.body);
      setState(() {
        _movies = List<Movie>.from(
            parsed['results'].map((json) => Movie.fromJson(json))); // si pas d'erreur affiche les films
      });
    } else {
      throw Exception("OUPS ! Il semblerait qu'il y ait une erreur..."); //si erreur affiche un mess erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Films'),
      ),
      body: GridView.builder( //liste avec colonnes
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // Définit les colonnes
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return Card(
            color: Colors.grey[800],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(// Image du film
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500/${movie.posterPath}',// URL de l'image du film.
                    fit: BoxFit.cover,// Ajuste l'image pour couvrir tte la zone
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),// Définit espacement de tt les côtés
                  child: Text(
                    movie.title,// Titre du film à afficher
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
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
