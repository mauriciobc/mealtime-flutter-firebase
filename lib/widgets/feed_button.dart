import 'package:flutter/material.dart';
import 'package:mealtime/models/cat_model.dart';

class FeedButton extends StatelessWidget {
  final Cat cat;
  final VoidCallback? onFed;
  final bool isLoading;

  const FeedButton({
    super.key,
    required this.cat,
    this.onFed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onFed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.restaurant, size: 16),
        label: const Text('Alimentar'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
