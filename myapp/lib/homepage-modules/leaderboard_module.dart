import 'package:flutter/material.dart';

class LeaderboardModule extends StatelessWidget {
  final VoidCallback goBack;

  const LeaderboardModule({super.key, required this.goBack});

  @override
  Widget build(BuildContext context) {
    // Temporary leaderboard page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
      ),
      body: ListView.builder(
        itemCount: 10, // Temporary dummy data
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('User ${index + 1}'),
            trailing: Text('${(10 - index) * 5} pts'),
          );
        },
      ),
    );
  }
}
