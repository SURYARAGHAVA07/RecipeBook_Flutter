import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/filter_store.dart';
import '../stores/recipe_store.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});
  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late FilterStore fstore;
  late RecipeStore rstore;
  final TextEditingController _ctr = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fstore = Provider.of<FilterStore>(context);
    rstore = Provider.of<RecipeStore>(context, listen: false);
  }

  void apply() {
    rstore.comprehensiveFilter(
      query: fstore.query.value,
      cuisines: fstore.cuisines.toList(),
      difficulty: fstore.difficulty.value,
      isVegetarian: fstore.isVegetarian.value,
      isVegan: fstore.isVegan.value,
      maxReadyTime: fstore.maxReadyTime.value,
      minServings: fstore.minServings.value,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filters'),
        actions: [
          TextButton(
            onPressed: apply, 
            child: const Text(
              'Apply', 
              style: TextStyle(color: Colors.white)
            )
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Observer(
          builder: (_) {
            _ctr.text = fstore.query.value;
            return ListView(
              children: [
                // Search field
                TextField(
                  controller: _ctr,
                  decoration: const InputDecoration(
                    labelText: 'Search by name or ingredient',
                    prefixIcon: Icon(Icons.search)
                  ),
                  onChanged: (v) => fstore.setQuery(v),
                ),
                const SizedBox(height: 12),
                
                // Dietary filters
                const Text(
                  'Dietary Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Observer(
                      builder: (_) => Checkbox(
                        value: fstore.isVegetarian.value,
                        onChanged: (v) => fstore.setIsVegetarian(v ?? false),
                      ),
                    ),
                    const Text('Vegetarian'),
                    const SizedBox(width: 16),
                    Observer(
                      builder: (_) => Checkbox(
                        value: fstore.isVegan.value,
                        onChanged: (v) => fstore.setIsVegan(v ?? false),
                      ),
                    ),
                    const Text('Vegan'),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Cuisine filters
                const Text(
                  'Cuisines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Indian', 'Chinese', 'Italian', 'American', 
                    'Mexican', 'Thai', 'Japanese', 'French', 
                    'Greek', 'Spanish', 'Korean', 'Vietnamese'
                  ].map((c) {
                    return Observer(builder: (_) {
                      final selected = fstore.cuisines.contains(c);
                      return FilterChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (_) => fstore.toggleCuisine(c),
                      );
                    });
                  }).toList(),
                ),
                const SizedBox(height: 12),
                
                // Difficulty filter
                const Text(
                  'Difficulty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Observer(builder: (_) {
                  return DropdownButtonFormField<String>(
                    value: fstore.difficulty.value.isEmpty ? null : fstore.difficulty.value,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Any')),
                      DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level'
                    ),
                    onChanged: (v) => fstore.setDifficulty(v ?? ''),
                  );
                }),
                const SizedBox(height: 12),
                
                // Time filter
                const Text(
                  'Maximum Preparation Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Observer(builder: (_) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: fstore.maxReadyTime.value.toDouble(),
                        min: 0,
                        max: 120,
                        divisions: 12,
                        label: fstore.maxReadyTime.value == 0 
                          ? 'No limit' 
                          : '${fstore.maxReadyTime.value} min',
                        onChanged: (v) => fstore.setMaxReadyTime(v.toInt()),
                      ),
                      Text(
                        fstore.maxReadyTime.value == 0 
                          ? 'No time limit' 
                          : 'Up to ${fstore.maxReadyTime.value} minutes'
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                
                // Servings filter
                const Text(
                  'Minimum Servings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Observer(builder: (_) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: fstore.minServings.value.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: fstore.minServings.value == 0 
                          ? 'No minimum' 
                          : '${fstore.minServings.value}+',
                        onChanged: (v) => fstore.setMinServings(v.toInt()),
                      ),
                      Text(
                        fstore.minServings.value == 0 
                          ? 'Any number of servings' 
                          : 'At least ${fstore.minServings.value} servings'
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => fstore.clear(), 
                      child: const Text('Clear Filters')
                    ),
                    ElevatedButton(
                      onPressed: apply, 
                      child: const Text('Apply Filters')
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}