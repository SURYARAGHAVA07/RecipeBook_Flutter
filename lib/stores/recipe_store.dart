import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/cuisine_section.dart';
import '../services/api_service.dart';
import '../services/local_data_service.dart';
import '../services/storage_service.dart';

class RecipeStore {
  final ApiService api = ApiService();
  final LocalDataService local = LocalDataService();
  final StorageService storage;
  bool _favoritesLoaded = false;

  // Observables
  final ObservableList<Recipe> allRecipes = ObservableList<Recipe>();
  final ObservableList<Recipe> displayed = ObservableList<Recipe>();
  final ObservableList<String> favorites = ObservableList<String>();
  final Observable<bool> isLoading = Observable(false);
  final Observable<String?> errorMessage = Observable(null);
  final Observable<bool> hasMore = Observable(true); // For pagination
  final ObservableMap<String, List<Recipe>> cuisineRecipes = ObservableMap<String, List<Recipe>>(); // For cuisine sections
  final ObservableMap<String, bool> cuisineLoading = ObservableMap<String, bool>(); // Loading state for each cuisine
  final ObservableMap<String, bool> cuisineHasMore = ObservableMap<String, bool>(); // Pagination for each cuisine
  final ObservableMap<String, int> cuisineOffsets = ObservableMap<String, int>(); // Offset for each cuisine
  
  int _currentPage = 0;
  static const int _pageSize = 12; // Load 12 recipes per page

  RecipeStore(this.storage) {
    // initialize favorites from storage
    _loadFavoritesFromStorage();
    
    // Initialize cuisine sections
    _initializeCuisineSections();
  }

  Future<void> _loadFavoritesFromStorage() async {
    try {
      final storedFavorites = storage.getFavorites();
      runInAction(() {
        favorites.addAll(storedFavorites);
        _favoritesLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading favorites from storage: $e');
      runInAction(() {
        _favoritesLoaded = true;
      });
    }
  }

  void _initializeCuisineSections() {
    final sections = [
      CuisineSection.indian(),
      CuisineSection.chinese(),
      CuisineSection.indianChinese(),
      CuisineSection.desserts(),
      CuisineSection.fastFood(),
    ];
    
    for (final section in sections) {
      final key = section.isCuisine ? section.cuisine : section.type;
      cuisineRecipes[key] = [];
      cuisineLoading[key] = false;
      cuisineHasMore[key] = true;
      cuisineOffsets[key] = 0;
    }
  }

  /// Load recipes from local JSON
  Future<void> loadLocal() async {
    runInAction(() {
      isLoading.value = true;
      errorMessage.value = null;
    });
    try {
      final list = await local.loadSampleRecipes();
      runInAction(() {
        allRecipes
          ..clear()
          ..addAll(list);
        displayed
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      debugPrint('Error loading local recipes: $e');
      runInAction(() => errorMessage.value = 'Failed to load local recipes');
    } finally {
      runInAction(() => isLoading.value = false);
    }
  }

  /// Load random recipes from Spoonacular API
  Future<void> loadRandomFromApi({int n = 12}) async {
    runInAction(() {
      isLoading.value = true;
      errorMessage.value = null;
    });
    try {
      final list = await api.getRandomSelection(n: n);
      runInAction(() {
        allRecipes
          ..clear()
          ..addAll(list);
        displayed
          ..clear()
          ..addAll(list);
        _currentPage = 0;
        hasMore.value = list.length >= n; // If we got less than requested, we've reached the end
      });
    } catch (e) {
      debugPrint('Error loading recipes from API: $e');
      runInAction(() => errorMessage.value = e.toString());
      // Fallback to local data if API fails
      await loadLocal();
    } finally {
      runInAction(() => isLoading.value = false);
    }
  }

  /// Load more random recipes (for pagination)
  Future<void> loadMoreRandomRecipes() async {
    if (!hasMore.value || isLoading.value) return;
    
    runInAction(() => isLoading.value = true);
    try {
      final list = await api.getRandomSelection(n: _pageSize);
      runInAction(() {
        allRecipes.addAll(list);
        displayed.addAll(list);
        _currentPage++;
        hasMore.value = list.length >= _pageSize; // If we got less than requested, we've reached the end
      });
    } catch (e) {
      debugPrint('Error loading more recipes from API: $e');
      runInAction(() => errorMessage.value = e.toString());
    } finally {
      runInAction(() => isLoading.value = false);
    }
  }

  /// Search recipes by name using Spoonacular API
  Future<void> searchRecipes(String query, {int offset = 0}) async {
    if (query.isEmpty) {
      // If query is empty, load random recipes
      await loadRandomFromApi();
      return;
    }

    // Determine if this is the first page or a subsequent page
    final isFirstPage = offset == 0;
    
    if (isFirstPage) {
      runInAction(() {
        isLoading.value = true;
        errorMessage.value = null;
      });
    } else {
      // For subsequent pages, we don't want to show the loading indicator over the entire grid
      runInAction(() => errorMessage.value = null);
    }
    
    try {
      final list = await api.searchByName(query, number: _pageSize, offset: offset);
      
      if (isFirstPage) {
        // First page of search results
        runInAction(() {
          allRecipes
            ..clear()
            ..addAll(list);
          displayed
            ..clear()
            ..addAll(list);
          _currentPage = 0;
          hasMore.value = list.length >= _pageSize;
        });
      } else {
        // Additional search results
        runInAction(() {
          allRecipes.addAll(list);
          displayed.addAll(list);
          _currentPage = offset ~/ _pageSize;
          hasMore.value = list.length >= _pageSize;
        });
      }
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      runInAction(() => errorMessage.value = e.toString());
      // Clear lists on error only for first page
      if (isFirstPage) {
        runInAction(() {
          allRecipes.clear();
          displayed.clear();
        });
      }
    } finally {
      if (isFirstPage) {
        runInAction(() => isLoading.value = false);
      }
    }
  }

  /// Comprehensive search that searches by name, ingredient, etc.
  Future<void> comprehensiveSearch(String query, {int offset = 0}) async {
    if (query.isEmpty) {
      // If query is empty, load random recipes
      await loadRandomFromApi();
      return;
    }

    // Determine if this is the first page or a subsequent page
    final isFirstPage = offset == 0;
    
    if (isFirstPage) {
      runInAction(() {
        isLoading.value = true;
        errorMessage.value = null;
      });
    } else {
      // For subsequent pages, we don't want to show the loading indicator over the entire grid
      runInAction(() => errorMessage.value = null);
    }
    
    try {
      final list = await api.comprehensiveSearch(query, number: _pageSize, offset: offset);
      
      if (isFirstPage) {
        // First page of search results
        runInAction(() {
          allRecipes
            ..clear()
            ..addAll(list);
          displayed
            ..clear()
            ..addAll(list);
          _currentPage = 0;
          hasMore.value = list.length >= _pageSize;
        });
      } else {
        // Additional search results
        runInAction(() {
          allRecipes.addAll(list);
          displayed.addAll(list);
          _currentPage = offset ~/ _pageSize;
          hasMore.value = list.length >= _pageSize;
        });
      }
    } catch (e) {
      debugPrint('Error in comprehensive search: $e');
      runInAction(() => errorMessage.value = e.toString());
      // Clear lists on error only for first page
      if (isFirstPage) {
        runInAction(() {
          allRecipes.clear();
          displayed.clear();
        });
      }
    } finally {
      if (isFirstPage) {
        runInAction(() => isLoading.value = false);
      }
    }
  }

  /// Load more search results (for pagination)
  Future<void> loadMoreSearchResults(String query) async {
    if (!hasMore.value || isLoading.value) return;
    await comprehensiveSearch(query, offset: (_currentPage + 1) * _pageSize);
  }

  /// Load recipes for a specific cuisine/type section
  Future<void> loadCuisineRecipes(CuisineSection section, {bool loadMore = false}) async {
    final key = section.isCuisine ? section.cuisine : section.type;
    
    // Check if we're already loading or if there's no more data
    if (cuisineLoading[key]! || !cuisineHasMore[key]!) return;
    
    final offset = loadMore ? cuisineOffsets[key]! : 0;
    final isFirstPage = !loadMore;
    
    runInAction(() => cuisineLoading[key] = true);
    
    try {
      List<Recipe> list;
      if (section.isCuisine) {
        list = await api.getRecipesByCuisine(section.cuisine, number: 6, offset: offset);
      } else {
        list = await api.getRecipesByType(section.type, number: 6, offset: offset);
      }
      
      runInAction(() {
        if (isFirstPage) {
          cuisineRecipes[key] = list;
        } else {
          cuisineRecipes[key] = [...cuisineRecipes[key]!, ...list];
        }
        
        // Update offset for next load
        cuisineOffsets[key] = offset + list.length;
        
        // If we got fewer than 6 recipes, we've reached the end
        cuisineHasMore[key] = list.length >= 6;
      });
    } catch (e) {
      debugPrint('Error loading ${section.title} recipes: $e');
    } finally {
      runInAction(() => cuisineLoading[key] = false);
    }
  }

  /// Load more recipes for a specific cuisine/type section
  Future<void> loadMoreCuisineRecipes(CuisineSection section) async {
    await loadCuisineRecipes(section, loadMore: true);
  }

  /// Load all cuisine sections
  Future<void> loadAllCuisineSections() async {
    final sections = [
      CuisineSection.indian(),
      CuisineSection.chinese(),
      CuisineSection.indianChinese(),
      CuisineSection.desserts(),
      CuisineSection.fastFood(),
    ];
    
    // Load first batch for all sections
    for (final section in sections) {
      await loadCuisineRecipes(section);
    }
  }

  /// Replace displayed list (used by filters)
  void setDisplayed(List<Recipe> list) {
    runInAction(() {
      displayed
        ..clear()
        ..addAll(list);
    });
  }

  /// Toggle favorite and persist to storage
  void toggleFavorite(String id) {
    runInAction(() {
      if (favorites.contains(id)) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
    });
    
    // Persist to storage asynchronously (fire and forget)
    _persistFavorites();
  }
  
  /// Persist favorites to storage
  Future<void> _persistFavorites() async {
    try {
      // Use a delayed async save to avoid blocking the UI
      Future.microtask(() async {
        try {
          await storage.saveFavorites(favorites.toList());
        } catch (e) {
          debugPrint('Error saving favorites to storage: $e');
        }
      });
    } catch (e) {
      debugPrint('Error scheduling favorites save: $e');
    }
  }

  /// Check if a recipe is favorited
  bool isFavorited(String id) => favorites.contains(id);

  /// Filter helper (query + optional cuisine/difficulty)
  void filter(String query, {List<String>? cuisines, List<String>? diets, String? difficulty}) {
    final q = query.toLowerCase().trim();
    final cuisineList = cuisines ?? [];
    final diff = (difficulty ?? '').toLowerCase();

    final result = allRecipes.where((r) {
      final titleMatch = r.title.toLowerCase().contains(q);
      final ingredientMatch = r.ingredients.any((ing) => ing.name.toLowerCase().contains(q));
      final cuisineMatch = q.isEmpty || r.area.toLowerCase().contains(q);
      final cuisineFilter = cuisineList.isEmpty || cuisineList.contains(r.area);
      final difficultyFilter = diff.isEmpty || r.category.toLowerCase() == diff;
      return (titleMatch || ingredientMatch || cuisineMatch) && cuisineFilter && difficultyFilter;
    }).toList();

    setDisplayed(result);
  }

  /// Comprehensive filter with all options
  void comprehensiveFilter({
    String? query,
    List<String>? cuisines,
    String? difficulty,
    bool? isVegetarian,
    bool? isVegan,
    int? maxReadyTime,
    int? minServings,
  }) {
    final q = (query ?? '').toLowerCase().trim();
    final cuisineList = cuisines ?? [];
    final diff = (difficulty ?? '').toLowerCase();
    final vegFilter = isVegetarian ?? false;
    final veganFilter = isVegan ?? false;
    final maxTime = maxReadyTime ?? 0;
    final minServing = minServings ?? 0;

    final result = allRecipes.where((r) {
      // Text search
      final titleMatch = q.isEmpty || r.title.toLowerCase().contains(q);
      final ingredientMatch = q.isEmpty || r.ingredients.any((ing) => ing.name.toLowerCase().contains(q));
      final cuisineMatch = q.isEmpty || r.area.toLowerCase().contains(q);
      
      // Cuisine filter
      final cuisineFilter = cuisineList.isEmpty || cuisineList.contains(r.area);
      
      // Difficulty filter
      final difficultyFilter = diff.isEmpty || r.category.toLowerCase() == diff;
      
      // Vegetarian filter
      final vegetarianFilter = !vegFilter || r.isVegetarian;
      
      // Vegan filter
      final veganFilterCheck = !veganFilter || (r.isVegetarian && _isVeganRecipe(r));
      
      // Time filter
      final timeFilter = maxTime == 0 || r.readyInMinutes <= maxTime;
      
      // Servings filter
      final servingsFilter = minServing == 0 || r.servings >= minServing;
      
      return (titleMatch || ingredientMatch || cuisineMatch) && 
             cuisineFilter && 
             difficultyFilter && 
             vegetarianFilter && 
             veganFilterCheck && 
             timeFilter && 
             servingsFilter;
    }).toList();

    setDisplayed(result);
  }
  
  /// Helper to determine if a recipe is vegan (simplified check)
  bool _isVeganRecipe(Recipe recipe) {
    // This is a simplified check - in a real app, you'd check ingredients
    // For now, we'll assume vegetarian recipes with no dairy/eggs are vegan
    final nonVeganIngredients = [
      'milk', 'cheese', 'butter', 'egg', 'cream', 'yogurt', 'honey'
    ];
    
    return !recipe.ingredients.any((ingredient) => 
        nonVeganIngredients.any((nonVegan) => 
            ingredient.name.toLowerCase().contains(nonVegan)));
  }

  // helper to fetch detail by id
  Future<Recipe?> fetchById(String id) async {
    return api.lookupById(id);
  }
  
  // Clear error message
  void clearError() {
    runInAction(() => errorMessage.value = null);
  }
  
  // Getters for pagination state
  bool get hasMoreRecipes => hasMore.value;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get favoritesLoaded => _favoritesLoaded;
}