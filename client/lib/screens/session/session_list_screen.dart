import 'package:flutter/material.dart';
import 'voicecall_screen.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Sessions'),
        backgroundColor: Colors.blueGrey.shade900,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text('Session with Evaluator #\$i'),
            subtitle: const Text('AI-assisted voice session scheduled'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => VoiceCallScreen()));
              },
              child: const Text('Join'),
            ),
          ),
        ),
      ),
    );
  }
}
