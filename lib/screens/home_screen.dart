import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/recipe_store.dart';
import '../widgets/recipe_card.dart';
import '../routes.dart';
import '../stores/filter_store.dart';
import '../widgets/search_bar.dart';
import '../widgets/cuisine_section.dart';
import '../models/cuisine_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late RecipeStore recipeStore;
  late FilterStore filterStore;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchFocusNode.addListener(_onFocusChange);
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipeStore = Provider.of<RecipeStore>(context);
    filterStore = Provider.of<FilterStore>(context);
    
    // Load sample data by default and all cuisine sections
    if (recipeStore.allRecipes.isEmpty) {
      recipeStore.loadRandomFromApi();
      recipeStore.loadAllCuisineSections();
    }
  }

  void _scrollListener() {
    // Load more when scrolled to the bottom for main content
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_isSearching) {
        // Load more search results
        final query = filterStore.query.value;
        if (query.isNotEmpty) {
          recipeStore.loadMoreSearchResults(query);
        }
      } else {
        // Load more random recipes
        recipeStore.loadMoreRandomRecipes();
      }
    }
  }

  void _onFocusChange() {
    setState(() {
      // Update UI based on focus state if needed
    });
  }

  void _onSearchChanged(String q) {
    // update filter store and apply filter on recipe store
    filterStore.setQuery(q);
    setState(() {
      _isSearching = q.isNotEmpty;
    });
    
    if (q.isEmpty) {
      recipeStore.loadRandomFromApi();
    } else {
      // Use comprehensive search instead of regular search
      recipeStore.comprehensiveSearch(q);
    }
  }

  void _showFilters() {
    Navigator.pushNamed(context, Routes.search);
  }

  void _dismissKeyboard() {
    // Dismiss keyboard and clear focus
    _searchFocusNode.unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    // responsive columns: 1 for narrow, 2 for medium+
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width > 700 ? 2 : 1;

    return GestureDetector(
      onTap: _dismissKeyboard, // Tap anywhere to dismiss keyboard
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepOrange.shade50,
                Colors.pink.shade50,
                Colors.purple.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App bar with gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.deepOrange.shade400,
                        Colors.pink.shade400,
                        Colors.purple.shade400,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AppBar(
                    title: const Text(
                      'Recipe Book',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      // Removed search icon from app bar
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.favorites),
                        icon: const Icon(Icons.favorite, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Search bar with integrated filter button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomSearchBar(
                          hint: 'Search recipes, ingredients, dishes...',
                          onChanged: _onSearchChanged,
                          onClear: () {
                            // clear filters and show all
                            filterStore.clear();
                            recipeStore.clearError();
                            recipeStore.loadRandomFromApi();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                          focusNode: _searchFocusNode,
                        ),
                      ),
                      if (_isSearching)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepOrange.shade400,
                                  Colors.pink.shade400,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              onPressed: _showFilters,
                              icon: const Icon(Icons.filter_list, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Horizontal cuisine sections (only show when not searching)
                        if (!_isSearching) ...[
                          CuisineSectionWidget(section: CuisineSection.indian()),
                          CuisineSectionWidget(section: CuisineSection.chinese()),
                          CuisineSectionWidget(section: CuisineSection.indianChinese()),
                          CuisineSectionWidget(section: CuisineSection.desserts()),
                          CuisineSectionWidget(section: CuisineSection.fastFood()),
                        ],
                        
                        // Main grid section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isSearching ? 'Search Results' : 'Featured Recipes',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade800,
                                ),
                              ),
                              if (!_isSearching)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${recipeStore.allRecipes.length} recipes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.deepOrange.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Observer(builder: (_) {
                          if (recipeStore.isLoading.value && recipeStore.allRecipes.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.deepOrange.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Preparing delicious recipes...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          // Show error message if there is one
                          if (recipeStore.errorMessage.value != null && recipeStore.allRecipes.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.error,
                                        size: 48,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Error: ${recipeStore.errorMessage.value}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        recipeStore.clearError();
                                        if (_isSearching && filterStore.query.value.isNotEmpty) {
                                          recipeStore.comprehensiveSearch(filterStore.query.value);
                                        } else {
                                          recipeStore.loadRandomFromApi();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          final list = recipeStore.displayed.toList();
                          if (list.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.search_off,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'No recipes found',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Try a different search term or adjust filters',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxis,
                                childAspectRatio: 0.7, // Adjusted for better card layout
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: list.length + (recipeStore.hasMoreRecipes ? 1 : 0),
                              itemBuilder: (c, i) {
                                // Show loading indicator at the end if there are more recipes
                                if (i == list.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.deepOrange.shade400,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                
                                final r = list[i];
                                return Observer(
                                  builder: (_) {
                                    final isFav = recipeStore.isFavorited(r.id);
                                    return RecipeCard(
                                      recipe: r,
                                      isFavorite: isFav,
                                      onTap: () => Navigator.pushNamed(context, Routes.detail, arguments: r.id),
                                      onFavorite: () => recipeStore.toggleFavorite(r.id),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}