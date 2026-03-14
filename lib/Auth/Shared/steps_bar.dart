// lib/Auth/Shared/steps_bar.dart
import 'package:flutter/material.dart';

class StepsBar extends StatelessWidget {
  final int activeIndex; // 0-based
  final int steps;
  final bool loading;
  const StepsBar({
    super.key,
    required this.activeIndex,
    required this.steps,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot(int n, bool active) => CircleAvatar(
      radius: 14,
      backgroundColor: Colors.white.withOpacity(active ? 0.95 : 0.35),
      child: Text(
        '$n',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(steps * 2 - 1, (i) {
            if (i.isOdd) {
              return Container(
                width: 40,
                height: 2,
                color: Colors.white.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              );
            }
            final stepIndex = i ~/ 2;
            return dot(stepIndex + 1, stepIndex == activeIndex);
          }),
        ),
        if (loading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            minHeight: 4,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ],
      ],
    );
  }
}
