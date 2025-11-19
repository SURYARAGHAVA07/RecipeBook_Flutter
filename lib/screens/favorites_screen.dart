import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/recipe_store.dart';
import '../widgets/recipe_card.dart';
import '../routes.dart';
import '../models/recipe.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> favoriteRecipes = [];
  bool isLoading = false;
  String? errorMessage;
  Set<String> _lastFavoriteIds = <String>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavoriteRecipesIfNeeded();
  }

  void _loadFavoriteRecipesIfNeeded() {
    final store = Provider.of<RecipeStore>(context, listen: false);
    final currentFavoriteIds = Set<String>.from(store.favorites);
    
    // Only reload if the favorites have actually changed
    if (currentFavoriteIds.length != _lastFavoriteIds.length || 
        currentFavoriteIds.difference(_lastFavoriteIds).isNotEmpty ||
        _lastFavoriteIds.difference(currentFavoriteIds).isNotEmpty) {
      _lastFavoriteIds = currentFavoriteIds;
      _loadFavoriteRecipes();
    }
  }

  Future<void> _loadFavoriteRecipes() async {
    final store = Provider.of<RecipeStore>(context, listen: false);
    final favIds = store.favorites.toList();
    
    // Always clear and reload
    setState(() {
      favoriteRecipes = [];
      isLoading = true;
      errorMessage = null;
    });
    
    if (favIds.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    
    try {
      // Load recipe details for all favorite IDs
      final recipes = <Recipe>[];
      
      // Fetch each recipe individually
      for (final id in favIds) {
        try {
          final recipe = await store.fetchById(id);
          if (recipe != null) {
            recipes.add(recipe);
          }
        } catch (e) {
          debugPrint('Error fetching favorite recipe $id: $e');
          // Continue with other recipes even if one fails
        }
      }
      
      // Only update if we're still mounted
      if (mounted) {
        setState(() {
          favoriteRecipes = recipes;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading favorites. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<RecipeStore>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavoriteRecipes,
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          // Check if favorites have changed and reload if needed
          _loadFavoriteRecipesIfNeeded();
          
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your favorite recipes...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavoriteRecipes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (store.favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on recipes to add them here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          if (favoriteRecipes.isEmpty && store.favorites.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  const Text(
                    'Loading favorites...',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  const Text(
                    'Fetching your favorite recipes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavoriteRecipes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async => _loadFavoriteRecipes(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: favoriteRecipes.length,
                itemBuilder: (c, i) {
                  final r = favoriteRecipes[i];
                  return RecipeCard(
                    recipe: r,
                    isFavorite: true,
                    onTap: () => Navigator.pushNamed(context, Routes.detail, arguments: r.id),
                    onFavorite: () {
                      store.toggleFavorite(r.id);
                      // Refresh the list after toggling
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _loadFavoriteRecipes();
                        // Update the last favorite IDs to prevent infinite refresh
                        _lastFavoriteIds = Set<String>.from(store.favorites);
                      });
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}