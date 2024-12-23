import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/post_card.dart';

class HomePage extends StatelessWidget {

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          PostCard(postId: '2'),
          //PostCard(postId: '2'),
          //PostCard(postId: '3'),
        ],
      ),
    );
  }
}

