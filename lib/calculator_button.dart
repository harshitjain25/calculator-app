import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.onLongPress,
    this.highlighted = false,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onPressed,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: FilledButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: FilledButton.styleFrom(
          backgroundColor: highlighted
              ? colors.primary
              : colors.surfaceContainerHighest,
          foregroundColor: highlighted ? colors.onPrimary : colors.onSurface,
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
