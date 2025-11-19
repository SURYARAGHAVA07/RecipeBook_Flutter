import 'ingredient.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final String area; // cuisine
  final String instructions;
  final String image;
  final List<Ingredient> ingredients;
  final int prepMinutes;
  final int cookMinutes;
  final int readyInMinutes;
  final int servings;
  final bool isVegetarian; // Added vegetarian flag

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.area,
    required this.instructions,
    required this.image,
    required this.ingredients,
    this.prepMinutes = 0,
    this.cookMinutes = 0,
    this.readyInMinutes = 0,
    this.servings = 0,
    this.isVegetarian = false, // Default to false
  });

  factory Recipe.fromMealDb(Map<String, dynamic> map) {
    // TheMealDB rows: strIngredient1..20 and strMeasure1..20
    List<Ingredient> ingredientList = [];
    for (int i = 1; i <= 20; i++) {
      final ing = map['strIngredient$i'];
      final meas = map['strMeasure$i'];
      if (ing != null && ing.toString().trim().isNotEmpty) {
        ingredientList.add(Ingredient(name: ing.toString().trim(), measure: meas?.toString().trim() ?? ''));
      }
    }
    
    // Determine if vegetarian based on category
    final category = map['strCategory'] ?? '';
    final isVeg = _isCategoryVegetarian(category.toString());
    
    return Recipe(
      id: map['idMeal'] ?? '',
      title: map['strMeal'] ?? '',
      category: category,
      area: map['strArea'] ?? '',
      instructions: map['strInstructions'] ?? '',
      image: map['strMealThumb'] ?? '',
      ingredients: ingredientList,
      isVegetarian: isVeg,
    );
  }

  factory Recipe.fromSpoonacular(Map<String, dynamic> map) {
    List<Ingredient> ingredientList = [];
    bool isVegetarian = false;
    
    if (map['vegetarian'] != null) {
      isVegetarian = map['vegetarian'] as bool? ?? false;
    }
    
    if (map['extendedIngredients'] != null) {
      final ingredientsData = map['extendedIngredients'] as List<dynamic>;
      ingredientList = ingredientsData.map((ingredientData) {
        final ingredientMap = ingredientData as Map<String, dynamic>;
        return Ingredient(
          name: ingredientMap['name']?.toString() ?? '',
          measure: '${ingredientMap['amount'] ?? ''} ${ingredientMap['unit'] ?? ''}'.trim(),
        );
      }).toList();
    } else if (map['missedIngredients'] != null || map['usedIngredients'] != null) {
      // Handle the structure returned by findByIngredients endpoint
      final missed = map['missedIngredients'] as List<dynamic>? ?? [];
      final used = map['usedIngredients'] as List<dynamic>? ?? [];
      final allIngredients = [...missed, ...used];
      
      ingredientList = allIngredients.map((ingredientData) {
        final ingredientMap = ingredientData as Map<String, dynamic>;
        return Ingredient(
          name: ingredientMap['name']?.toString() ?? '',
          measure: '${ingredientMap['amount'] ?? ''} ${ingredientMap['unit'] ?? ''}'.trim(),
        );
      }).toList();
    }

    return Recipe(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['dishTypes'] != null && (map['dishTypes'] as List<dynamic>).isNotEmpty 
        ? (map['dishTypes'] as List<dynamic>).first.toString() 
        : 'Unknown',
      area: map['cuisines'] != null && (map['cuisines'] as List<dynamic>).isNotEmpty 
        ? (map['cuisines'] as List<dynamic>).first.toString() 
        : 'Unknown',
      instructions: map['instructions']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      ingredients: ingredientList,
      readyInMinutes: map['readyInMinutes'] is int ? map['readyInMinutes'] : 0,
      servings: map['servings'] is int ? map['servings'] : 0,
      isVegetarian: isVegetarian,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? json['idMeal'] ?? '',
      title: json['title'] ?? json['strMeal'] ?? '',
      category: json['category'] ?? json['strCategory'] ?? '',
      area: json['area'] ?? json['strArea'] ?? '',
      instructions: json['instructions'] ?? json['strInstructions'] ?? '',
      image: json['image'] ?? json['strMealThumb'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => Ingredient.fromMap(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      readyInMinutes: json['readyInMinutes'] is int ? json['readyInMinutes'] : 0,
      servings: json['servings'] is int ? json['servings'] : 0,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'area': area,
    'instructions': instructions,
    'image': image,
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    'readyInMinutes': readyInMinutes,
    'servings': servings,
    'isVegetarian': isVegetarian,
  };
  
  // Helper method to determine if a category is vegetarian
  static bool _isCategoryVegetarian(String category) {
    final vegetarianCategories = [
      'Vegetarian',
      'Vegan',
      'Side Dish',
      'Dessert',
      'Salad',
      'Soup',
      'Snack',
      'Breakfast',
      'Starter',
    ];
    
    return vegetarianCategories.any((vegCategory) => 
        category.toLowerCase().contains(vegCategory.toLowerCase()));
  }
}