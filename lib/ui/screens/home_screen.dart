import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:movieapp/core/providers/movie_provider.dart';
import 'package:movieapp/ui/screens/detail_screen.dart';
import 'package:movieapp/ui/screens/login_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSearchActive = false;
  final _searchController = TextEditingController();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      MoviesList(searchController: _searchController),
      const FavoritesScreenPlaceholder(),
      const MoreScreen(),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_isSearchActive) {
        _isSearchActive = false;
        _searchController.clear();
        Provider.of<MovieProvider>(context, listen: false).clearSearch();
      }
    });
  }

  void _showNotificationsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const NotificationsSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_isSearchActive) {
          setState(() {
            _isSearchActive = false;
            _searchController.clear();
            movieProvider.clearSearch();
          });
          return;
        }
        
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        // --- CAMBIO: AppBar ahora tiene transiciones animadas internas ---
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isSearchActive && _selectedIndex == 0
                ? TextField(
                    key: const ValueKey('SearchField'),
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar películas...',
                      border: InputBorder.none,
                    ),
                    onChanged: movieProvider.onSearchChanged,
                  )
                : Text(
                    _getAppBarTitle(_selectedIndex),
                    key: ValueKey(_getAppBarTitle(_selectedIndex)),
                  ),
          ),
          leading: _isSearchActive && _selectedIndex == 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = false;
                      _searchController.clear();
                      movieProvider.clearSearch();
                    });
                  },
                )
              : null,
          automaticallyImplyLeading: false,
          actions: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isSearchActive && _selectedIndex == 0
                  ? IconButton(
                      key: const ValueKey('close'),
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _searchController.clear();
                          movieProvider.clearSearch();
                        }
                      },
                    )
                  : Row(
                      key: const ValueKey('actions'),
                      children: [
                        if (_selectedIndex == 0)
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                _isSearchActive = true;
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => _showNotificationsPanel(context),
                        ),
                      ],
                    ),
            )
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              activeIcon: Icon(Icons.movie_filter),
              label: 'Películas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              activeIcon: Icon(Icons.more_horiz),
              label: 'Más',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Películas Populares';
      case 1:
        return 'Mis Favoritos';
      case 2:
        return 'Más Opciones';
      default:
        return 'MovieApp';
    }
  }
}

class MoviesList extends StatefulWidget {
  final TextEditingController searchController;
  const MoviesList({super.key, required this.searchController});

  @override
  State<MoviesList> createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  // --- NUEVO: ScrollController para ocultar el teclado ---
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
       final provider = Provider.of<MovieProvider>(context, listen: false);
       if (provider.popularMovies.isEmpty) {
         provider.fetchPopularMovies();
       }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- NUEVO: Lógica para ocultar el teclado ---
  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection == ScrollDirection.forward) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        final theme = Theme.of(context);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBody(movieProvider, theme),
        );
      },
    );
  }

  Widget _buildBody(MovieProvider movieProvider, ThemeData theme) {
    if (movieProvider.isLoading) {
      return Center(
        key: const ValueKey('loading'),
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    final movies = movieProvider.isSearching
        ? movieProvider.searchedMovies
        : movieProvider.popularMovies;

    if (movies.isEmpty && movieProvider.isSearching) {
      return Center(
        key: const ValueKey('no-results'),
        child: Text(
          'No se encontraron resultados.',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      // --- CAMBIO: Añadimos el controller al ListView ---
      controller: _scrollController,
      key: const ValueKey('results-list'),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailScreen(movie: movie)),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: movie.posterPath,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100,
                            height: 150,
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 150,
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            child: Icon(Icons.movie, color: theme.iconTheme.color, size: 40),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.overview,
                            style: theme.textTheme.bodySmall,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FavoritesScreenPlaceholder extends StatelessWidget {
  const FavoritesScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tus películas favoritas aparecerán aquí.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Tu Información'),
          onTap: () { /* Lógica futura */ },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Acerca de'),
          onTap: () { /* Lógica futura */ },
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Información Legal'),
          onTap: () { /* Lógica futura */ },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text('Cerrar Sesión', style: TextStyle(color: theme.colorScheme.error)),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.new_releases, color: Theme.of(context).colorScheme.primary),
            title: const Text('¡Nuevos Estrenos!'),
            subtitle: const Text('No te pierdas las películas que llegan esta semana.'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.confirmation_number, color: Theme.of(context).colorScheme.secondary),
            title: const Text('Promoción Especial'),
            subtitle: const Text('2x1 en dulcería todos los martes.'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Actualización de Cuenta'),
            subtitle: const Text('Tu información ha sido actualizada.'),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

