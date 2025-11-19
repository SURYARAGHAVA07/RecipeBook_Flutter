import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/recipe.dart';

class ApiService {
  final String base = spoonacularBase;
  final String apiKey = spoonacularApiKey;

  Future<List<Recipe>> searchByName(String query, {int number = 12, int offset = 0}) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    final uri = Uri.parse('$base/recipes/complexSearch?apiKey=$apiKey&query=$query&number=$number&offset=$offset&addRecipeInformation=true');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body);
      final results = map['results'];
      if (results == null) return [];
      return (results as List).map((m) => Recipe.fromSpoonacular(m as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to search: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<Recipe>> searchByIngredient(String ingredient, {int number = 12, int offset = 0}) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    final uri = Uri.parse('$base/recipes/findByIngredients?apiKey=$apiKey&ingredients=$ingredient&number=$number&offset=$offset&ranking=1');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final results = jsonDecode(res.body) as List;
      // The findByIngredients endpoint returns a different structure, so we need to adapt it
      return results.map((m) => Recipe.fromSpoonacular(m as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to search by ingredient: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<Recipe>> comprehensiveSearch(String query, {int number = 12, int offset = 0}) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    // First try searching by name/title
    try {
      final nameResults = await searchByName(query, number: number, offset: offset);
      return nameResults;
    } catch (e) {
      // If that fails, try searching by ingredient
      try {
        final ingredientResults = await searchByIngredient(query, number: number, offset: offset);
        return ingredientResults;
      } catch (e2) {
        // If both fail, throw the original error
        throw e;
      }
    }
  }

  Future<Recipe?> lookupById(String id) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    final uri = Uri.parse('$base/recipes/$id/information?apiKey=$apiKey');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body);
      return Recipe.fromSpoonacular(map as Map<String, dynamic>);
    } else {
      throw Exception('Failed lookup: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<Recipe>> getRandomRecipes({int number = 12}) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    final uri = Uri.parse('$base/recipes/random?apiKey=$apiKey&number=$number');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body);
      final recipes = map['recipes'];
      if (recipes == null) return [];
      return (recipes as List).map((m) => Recipe.fromSpoonacular(m as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to get random recipes: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<Recipe>> getRecipesByCuisine(String cuisine, {int number = 6, int offset = 0}) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    final uri = Uri.parse('$base/recipes/complexSearch?apiKey=$apiKey&cuisine=$cuisine&number=$number&offset=$offset&addRecipeInformation=true');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body);
      final results = map['results'];
      if (results == null) return [];
      return (results as List).map((m) => Recipe.fromSpoonacular(m as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to get recipes by cuisine: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<Recipe>> getRecipesByType(String type, {int number = 6, int offset = 0}) async {
    if (apiKey.isEmpty) {
      throw Exception('Spoonacular API key is missing. Please add your API key in constants.dart');
    }
    
    final uri = Uri.parse('$base/recipes/complexSearch?apiKey=$apiKey&type=$type&number=$number&offset=$offset&addRecipeInformation=true');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body);
      final results = map['results'];
      if (results == null) return [];
      return (results as List).map((m) => Recipe.fromSpoonacular(m as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to get recipes by type: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<Recipe>> getRandomSelection({int n = 12}) async {
    // Using getRandomRecipes instead of multiple individual calls
    return getRandomRecipes(number: n);
  }
}