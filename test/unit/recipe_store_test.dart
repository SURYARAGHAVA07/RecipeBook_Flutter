import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/stores/recipe_store.dart';
import 'package:recipe_book/services/storage_service.dart';

void main() {
  test('load local sample recipes', () async {
    final storage = StorageService();
    await storage.init();
    final store = RecipeStore(storage);
    await store.loadLocal();
    expect(store.allRecipes.isNotEmpty, true);
  });
}
