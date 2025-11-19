class CuisineSection {
  final String title;
  final String cuisine; // For cuisine-based sections
  final String type; // For type-based sections (desserts, etc.)
  final bool isCuisine; // true if cuisine-based, false if type-based

  CuisineSection({
    required this.title,
    required this.cuisine,
    required this.type,
    required this.isCuisine,
  });

  // Factory constructors for common sections
  factory CuisineSection.indian() => CuisineSection(
        title: 'Indian',
        cuisine: 'Indian',
        type: '',
        isCuisine: true,
      );

  factory CuisineSection.chinese() => CuisineSection(
        title: 'Chinese',
        cuisine: 'Chinese',
        type: '',
        isCuisine: true,
      );

  factory CuisineSection.indianChinese() => CuisineSection(
        title: 'Indo Chinese',
        cuisine: 'Indian,Chinese',
        type: '',
        isCuisine: true,
      );

  factory CuisineSection.desserts() => CuisineSection(
        title: 'Desserts',
        cuisine: '',
        type: 'dessert',
        isCuisine: false,
      );

  factory CuisineSection.fastFood() => CuisineSection(
        title: 'Fast Foods',
        cuisine: '',
        type: 'fast food',
        isCuisine: false,
      );

  // Factory constructor for custom sections
  factory CuisineSection.custom(String title, String cuisine, String type, bool isCuisine) => 
      CuisineSection(
        title: title,
        cuisine: cuisine,
        type: type,
        isCuisine: isCuisine,
      );
}