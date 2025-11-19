import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/search_filter_screen.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const detail = '/detail';
  static const favorites = '/favorites';
  static const auth = '/auth';
  static const search = '/search';

  static final routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    detail: (context) => const RecipeDetailScreen(),
    favorites: (context) => const FavoritesScreen(),
    auth: (context) => const AuthScreen(),
    search: (context) => const SearchFilterScreen(),
  };
}