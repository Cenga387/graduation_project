import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          PostCard(postId: '1'),
          //PostCard(postId: '2'),
          // PostCard(postId: '3'),
        ],
      ),
    );
  }
}
