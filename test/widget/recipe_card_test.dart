import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:recipe_book/widgets/recipe_card.dart';
import 'package:recipe_book/models/recipe.dart';

void main() {
  testWidgets('recipe card shows title and favorite', (WidgetTester tester) async {
    final recipe = Recipe(id: 'x', title: 'Test', category: 'Easy', area: 'Test', instructions: '', image: '', ingredients: []);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RecipeCard(recipe: recipe, onTap: () {}, onFavorite: () {}, isFavorite: false),
      ),
    ));
    expect(find.text('Test'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}
