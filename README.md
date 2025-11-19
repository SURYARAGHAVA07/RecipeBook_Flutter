# Recipe Book

A Flutter recipe application that uses the Spoonacular API to provide recipe data.

## Getting Started

This project is a Flutter application that allows users to browse, search, and view recipes.

### Prerequisites

- Flutter SDK
- Android Studio or VS Code
- Spoonacular API key (free tier available)

### Setup

1. Get a free API key from [Spoonacular](https://spoonacular.com/food-api)
2. Add your API key to `lib/constants.dart`:
   ```dart
   const String spoonacularApiKey = 'YOUR_API_KEY_HERE';
   ```
3. Run `flutter pub get` to install dependencies
4. Run the app with `flutter run`

### Features

- Browse random recipes on the home screen (now loads 12 recipes by default)
- Multiple horizontal scrolling sections for different cuisines:
  - Indian dishes
  - Chinese dishes
  - Indo-Chinese fusion
  - Desserts
  - Fast foods
- Each section loads 6 recipes initially and loads more as you scroll (80% threshold)
- Comprehensive search functionality that searches across:
  - Recipe names
  - Ingredients
  - Dish types
  - Cuisines
- Search results with pagination support
- Infinite scrolling to load more recipes as you scroll
- Favorite button on every recipe card for quick saving
- Favorite button on recipe detail page for easy access
- Favorite button in ingredients section for quick access
- View detailed recipe information including ingredients and instructions
- Save favorite recipes
- Responsive design that works on both mobile and tablet

### Dependencies

- provider: State management
- mobx: Reactive state management
- http: HTTP client for API requests
- cached_network_image: Image caching
- shared_preferences: Local data persistence
- share_plus: Share recipes with others

### API Endpoints Used

- `recipes/random`: Get random recipes
- `recipes/complexSearch`: Search recipes by query with pagination
- `recipes/findByIngredients`: Search recipes by ingredients
- `recipes/complexSearch?cuisine=`: Get recipes by cuisine
- `recipes/complexSearch?type=`: Get recipes by type
- `recipes/{id}/information`: Get detailed recipe information

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.