//import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class SectionPage extends StatelessWidget {
  final String title;
  const SectionPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
    );
  }
}
