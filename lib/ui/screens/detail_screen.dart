import 'package:flutter/material.dart';
import 'package:movieapp/core/models/movie.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // Obtenemos una referencia a los colores y estilos del tema actual.
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // El color se hereda del tema.
            expandedHeight: 500.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1,1))
                  ]
                ),
              ),
              centerTitle: true,
              background: Hero(
                tag: movie.posterPath,
                // --- MEJORA DE CARGA DE IMAGEN ---
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  fit: BoxFit.cover,
                  // Muestra un indicador de carga mientras la imagen descarga.
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: theme.scaffoldBackgroundColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    );
                  },
                  // Muestra un ícono si la imagen falla al cargar.
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.scaffoldBackgroundColor,
                      child: Icon(Icons.movie_creation_outlined, color: theme.iconTheme.color, size: 60),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      // Usamos los estilos de texto del tema.
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5, // Espacio entre líneas para mejor legibilidad
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Añadimos un espacio al final para que el scroll se vea mejor
              const SizedBox(height: 50),
            ]),
          ),
        ],
      ),
    );
  }
}
