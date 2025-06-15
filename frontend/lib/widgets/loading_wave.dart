import 'package:flutter/material.dart';

class LoadingWave extends StatelessWidget {
  final String message;

  const LoadingWave({super.key, this.message = "Listening..."});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircularProgressIndicator(strokeWidth: 3),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
