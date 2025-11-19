import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable custom search bar with debounce.
/// onChanged is invoked after [debounceDuration] of inactivity.
class CustomSearchBar extends StatefulWidget {
  final String? hint;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.hint,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
    this.onClear,
    this.focusNode,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    // keep controller text changes reflected for suffix icon
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      // we created the controller — dispose it
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(text);
    });
    setState(() {}); // update clear button visibility
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    setState(() {});
  }

  void _performSearch() {
    // Immediately trigger search without waiting for debounce
    _debounce?.cancel();
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                focusNode: widget.focusNode,
                onChanged: _onTextChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Search recipes...',
                  prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clear,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.pink.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}