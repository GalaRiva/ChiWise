import 'package:flutter/material.dart';

/// Временная заглушка экрана, используется в app_router.dart до тех пор,
/// пока соответствующий этап плана разработки не заменит её реальным UI.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
