class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      measure: map['measure'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'measure': measure};
}