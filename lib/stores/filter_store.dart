import 'package:mobx/mobx.dart';

class FilterStore {
  final Observable<String> query = Observable('');
  final ObservableList<String> cuisines = ObservableList<String>();
  final Observable<String> difficulty = Observable('');
  final Observable<bool> isVegetarian = Observable(false);
  final Observable<bool> isVegan = Observable(false);
  final Observable<int> maxReadyTime = Observable(0); // 0 means no limit
  final Observable<int> minServings = Observable(0); // 0 means no limit

  /// Set the current search query
  void setQuery(String q) {
    runInAction(() => query.value = q);
  }

  /// Toggle a cuisine filter on/off
  void toggleCuisine(String c) {
    runInAction(() {
      if (cuisines.contains(c)) {
        cuisines.remove(c);
      } else {
        cuisines.add(c);
      }
    });
  }

  /// Set difficulty filter
  void setDifficulty(String d) {
    runInAction(() => difficulty.value = d);
  }

  /// Set vegetarian filter
  void setIsVegetarian(bool value) {
    runInAction(() => isVegetarian.value = value);
  }

  /// Set vegan filter
  void setIsVegan(bool value) {
    runInAction(() => isVegan.value = value);
  }

  /// Set max ready time filter
  void setMaxReadyTime(int minutes) {
    runInAction(() => maxReadyTime.value = minutes);
  }

  /// Set min servings filter
  void setMinServings(int servings) {
    runInAction(() => minServings.value = servings);
  }

  /// Clear all filters
  void clear() {
    runInAction(() {
      query.value = '';
      cuisines.clear();
      difficulty.value = '';
      isVegetarian.value = false;
      isVegan.value = false;
      maxReadyTime.value = 0;
      minServings.value = 0;
    });
  }
}