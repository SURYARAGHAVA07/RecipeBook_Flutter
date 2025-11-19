import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/recipe_store.dart';
import '../widgets/ingredient_list.dart';
import '../widgets/step_by_step_view.dart';
import '../models/recipe.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with TickerProviderStateMixin {
  Recipe? recipe;
  bool loading = true;
  late RecipeStore recipeStore;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String?;
    recipeStore = Provider.of<RecipeStore>(context, listen: false);
    
    if (id != null) {
      recipeStore.fetchById(id).then((r) {
        setState(() {
          recipe = r;
          loading = false;
        });
      }).catchError((_) {
        setState(() => loading = false);
      });
    } else {
      // no id passed
      loading = false;
    }
  }

  void shareRecipe(Recipe r) {
    final sb = StringBuffer();
    sb.writeln(r.title);
    sb.writeln('Cuisine: ${r.area} • Category: ${r.category}');
    if (r.readyInMinutes > 0) sb.writeln('Ready in: ${r.readyInMinutes} minutes');
    if (r.servings > 0) sb.writeln('Servings: ${r.servings}');
    sb.writeln('\nIngredients:');
    for (final ing in r.ingredients) {
      sb.writeln('- ${ing.name} ${ing.measure}');
    }
    sb.writeln('\nSteps:\n${r.instructions}');
    Share.share(sb.toString(), subject: r.title);
  }
  
  void toggleFavorite() {
    if (recipe != null) {
      recipeStore.toggleFavorite(recipe!.id);
      // Animate the heart icon
      _heartController.forward().then((_) {
        _heartController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Container(
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preparing your recipe...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : recipe == null
          ? Container(
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recipe not found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
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
              child: CustomScrollView(
                slivers: [
                  // Sliver app bar with recipe image
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.deepOrange.shade400,
                    foregroundColor: Colors.white,
                    actions: [
                      Observer(
                        builder: (_) {
                          final isFavorite = recipeStore.isFavorited(recipe!.id);
                          return IconButton(
                            onPressed: toggleFavorite,
                            icon: ScaleTransition(
                              scale: _heartAnimation,
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.redAccent : Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () => shareRecipe(recipe!),
                        icon: const Icon(Icons.share, size: 28),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        recipe!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: recipe!.image,
                            fit: BoxFit.cover,
                            placeholder: (c, s) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepOrange.shade300,
                                    Colors.pink.shade300,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                            errorWidget: (c, s, e) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepOrange.shade300,
                                    Colors.pink.shade300,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.fastfood,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Gradient overlay for better text visibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Recipe details content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recipe title and favorite button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  recipe!.title,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade900,
                                  ),
                                ),
                              ),
                              Observer(
                                builder: (_) {
                                  final isFavorite = recipeStore.isFavorited(recipe!.id);
                                  return IconButton(
                                    onPressed: toggleFavorite,
                                    icon: ScaleTransition(
                                      scale: _heartAnimation,
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.redAccent : Colors.grey,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Cuisine and category tags with veg/non-veg indicator
                          Row(
                            children: [
                              // Veg/Non-veg indicator with square box
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: recipe!.isVegetarian ? Colors.green : Colors.red,
                                  border: Border.all(
                                    color: recipe!.isVegetarian ? Colors.green : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  recipe!.area,
                                  style: TextStyle(
                                    color: Colors.deepOrange.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  recipe!.category,
                                  style: TextStyle(
                                    color: Colors.purple.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Recipe metadata
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoChip(
                                  icon: Icons.access_time,
                                  label: '${recipe!.readyInMinutes} min',
                                  color: Colors.deepOrange.shade400,
                                ),
                                _buildInfoChip(
                                  icon: Icons.people,
                                  label: '${recipe!.servings} servings',
                                  color: Colors.pink.shade400,
                                ),
                                _buildInfoChip(
                                  icon: Icons.restaurant,
                                  label: '${recipe!.ingredients.length} ingredients',
                                  color: Colors.purple.shade400,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Ingredients section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: IngredientList(ingredients: recipe!.ingredients, recipe: recipe),
                          ),
                          const SizedBox(height: 24),
                          
                          // Instructions section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: StepByStepView(instructions: recipe!.instructions),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}