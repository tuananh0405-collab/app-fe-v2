import 'package:flutter/material.dart';

class StubScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  const StubScreen({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          subtitle ?? '🚧 Placeholder – sẽ triển khai logic ở bước sau.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
