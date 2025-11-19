import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import '../models/cuisine_section.dart';
import '../stores/recipe_store.dart';
import 'recipe_card.dart';
import '../routes.dart';

class CuisineSectionWidget extends StatefulWidget {
  final CuisineSection section;
  const CuisineSectionWidget({super.key, required this.section});

  @override
  State<CuisineSectionWidget> createState() => _CuisineSectionWidgetState();
}

class _CuisineSectionWidgetState extends State<CuisineSectionWidget> with SingleTickerProviderStateMixin {
  late RecipeStore recipeStore;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipeStore = Provider.of<RecipeStore>(context, listen: false);
    
    // Load initial recipes for this section
    recipeStore.loadCuisineRecipes(widget.section);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Load more when scrolled to 80% of the end
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final key = widget.section.isCuisine 
          ? widget.section.cuisine 
          : widget.section.type;
      
      // Check if we can load more
      if (recipeStore.cuisineHasMore[key]! && 
          !recipeStore.cuisineLoading[key]!) {
        recipeStore.loadMoreCuisineRecipes(widget.section);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.section.isCuisine 
        ? widget.section.cuisine 
        : widget.section.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.section.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getTitleColor(widget.section.title),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTitleColor(widget.section.title).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getTitleColor(widget.section.title),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300, // Increased height to accommodate the card properly
          child: Observer(
            builder: (_) {
              final recipes = recipeStore.cuisineRecipes[key] ?? [];
              final hasMore = recipeStore.cuisineHasMore[key] ?? true;

              return ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                itemCount: recipes.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end if there are more recipes
                  if (index == recipes.length && hasMore) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Show recipe card
                  if (index < recipes.length) {
                    final recipe = recipes[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Observer(
                        builder: (_) {
                          final isFavorite = recipeStore.isFavorited(recipe.id);
                          return RecipeCard(
                            recipe: recipe,
                            isFavorite: isFavorite,
                            onTap: () => Navigator.pushNamed(
                              context, 
                              Routes.detail, 
                              arguments: recipe.id,
                            ),
                            onFavorite: () => recipeStore.toggleFavorite(recipe.id),
                          );
                        },
                      ),
                    );
                  }

                  return null;
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Color _getTitleColor(String title) {
    switch (title.toLowerCase()) {
      case 'indian':
        return Colors.deepOrange;
      case 'chinese':
        return Colors.red;
      case 'indo chinese':
        return Colors.pink;
      case 'desserts':
        return Colors.purple;
      case 'fast foods':
        return Colors.blue;
      default:
        return Colors.deepOrange;
    }
  }
}