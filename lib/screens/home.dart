import 'package:flutter/material.dart';
import '../recipe.dart';

late Future<List<Recipe>> futureBrowseRecipe;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _fragments = [
    const PopularFragment(),
    const BrowseFragment(),
    const FavoritesFragment()
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  int _selectedTabIndex = 0;
  Widget _currentFragment = const PopularFragment();

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
      _currentFragment = index < _fragments.length ? _fragments[index] : const BrowseFragment();
    });
  }

  void _onSearchButtonPressed() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _selectedTabIndex = 1;
        futureBrowseRecipe = fetchRecipe('${_searchController.text} cupcake');

        _searchController.clearComposing();
        _searchController.clear();
        _searchFocusNode.unfocus();

        _currentFragment = const BrowseFragment();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureBrowseRecipe = fetchRecipe('cupcake');
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 80.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _currentFragment,
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: SearchBar(
                onTap: () {
                  _searchFocusNode.requestFocus();
                },
                controller: _searchController,
                focusNode: _searchFocusNode,
                backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).colorScheme.background
                ),
                shadowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.transparent
                ),
                leading: IconButton(
                  onPressed: () { } ,
                  icon: const Icon(Icons.menu_outlined),
                ),
                hintText: 'Search...',
                trailing: [
                  IconButton(
                    onPressed: _onSearchButtonPressed,
                    icon: const Icon(Icons.search_outlined),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Popular',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ]
      )
    );
  }
}

class BrowseFragment extends StatelessWidget {
  const BrowseFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: futureBrowseRecipe,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipe found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final recipe = snapshot.data![index];

                return RecipeCard(id: recipe.id, title: recipe.title, image: recipe.image);
              },
            );
          }
        } else {
          throw Exception();
        }
      },
    );
  }
}

class FavoritesFragment extends StatelessWidget {
  const FavoritesFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('All your saved recipe will be appear here.'));
  }
}

class PopularFragment extends StatelessWidget {
  const PopularFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: prefetchRecipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(
            id: prefetchRecipes[index]['id'],
            title: prefetchRecipes[index]['title'],
            image: prefetchRecipes[index]['image'],
            summary: prefetchRecipes[index]['summary'],
          );
        },
      ),
    );
  }
}