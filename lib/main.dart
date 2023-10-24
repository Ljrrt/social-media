import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(child: App()),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FilterWidget(),
          Consumer(builder: (context, ref, child) {
            final filter = ref.watch(favoritesStatusProvider);
            switch (filter) {
              case FavoriteStatus.all:
                return FilmsList(provider: allFilmsProvider);
              case FavoriteStatus.favorites:
                return FilmsList(provider: favoriteFilmsProvider);
              case FavoriteStatus.notFavorites:
                return FilmsList(provider: notFavoriteFilmsProvider);
            }
          })
        ],
      ),
    );
  }
}

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  @override
  String toString() =>
      'Film($id, title: $title, description: $description, is Favorite: $isFavorite)';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id || isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll(
        [
          id,
          isFavorite,
        ],
      );

  Film copy({required bool isFavorite}) {
    return Film(
      id: id,
      title: title,
      description: description,
      isFavorite: isFavorite,
    );
  }
}

const allFilms = [
  Film(
    id: '1',
    title: 'Film 1',
    description: 'Description 1',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'Film 2',
    description: 'Description 2',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'Film 3',
    description: 'Description 3',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'Film 4',
    description: 'Description 4',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update(Film film, bool isFavorite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? thisFilm.copy(isFavorite: isFavorite)
            : thisFilm)
        .toList();
  }
}

enum FavoriteStatus { all, favorites, notFavorites }

// favorite status provider
final favoritesStatusProvider =
    StateProvider<FavoriteStatus>((_) => FavoriteStatus.all);

// all films provider
final allFilmsProvider =
    StateNotifierProvider<FilmsNotifier, List<Film>>((_) => FilmsNotifier());
// favorites film provider
final favoriteFilmsProvider = Provider<Iterable<Film>>(
    (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavorite));

// not favorites film provider
final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
    (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavorite));

class FilmsList extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;

  const FilmsList({
    required this.provider,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          return ListTile(
              title: Text(film.title),
              subtitle: Text(film.description),
              trailing: IconButton(
                icon: favoriteIcon,
                onPressed: () {
                  final isFavorite = !film.isFavorite;
                  ref.read(allFilmsProvider.notifier).update(film, isFavorite);
                },
              ));
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return DropdownButton(
        items: FavoriteStatus.values
            .map((fs) => DropdownMenuItem(
                  value: fs,
                  onTap: () {},
                  child: Text(fs.name),
                ))
            .toList(),
        onChanged: (FavoriteStatus? fs) {
          ref.read(favoritesStatusProvider.notifier).state = fs!;
        },
        value: ref.watch(favoritesStatusProvider),
      );
    });
  }
}
