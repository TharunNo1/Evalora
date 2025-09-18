import 'package:flutter/material.dart';
import 'voice_chat_screen.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation Sessions')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text('Session with Evaluator #\$i'),
            subtitle: const Text('AI-assisted voice session scheduled'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                );
              },
              child: const Text('Join'),
            ),
          ),
        ),
      ),
    );
  }
}
