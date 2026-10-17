import 'package:flutter/material.dart';

import '../theme.dart';

/// Shown when the app is opened with a link it doesn't know.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  static const String title = 'Page not found';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.link_off,
                size: 56,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This link does not open any page in the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
