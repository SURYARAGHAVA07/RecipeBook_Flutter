import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe.dart';

class LocalDataService {
  Future<List<Recipe>> loadSampleRecipes() async {
    final data = await rootBundle.loadString('assets/data/sample_recipes.json');
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded.map((e) => Recipe.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}