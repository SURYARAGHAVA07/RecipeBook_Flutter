import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'stores/recipe_store.dart';
import 'stores/filter_store.dart';
import 'stores/auth_store.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<RecipeStore>(create: (_) => RecipeStore(storage)),
        Provider<FilterStore>(create: (_) => FilterStore()),
        Provider<AuthStore>(create: (_) => AuthStore(storage)),
      ],
      child: const MyApp(),
    ),
  );
}