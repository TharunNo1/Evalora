import 'package:flutter/material.dart';
import 'voicecall_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  Future<void> _openUrlForVoiceChat() async {
    const url = 'http://localhost:3000';

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

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
              onPressed: _openUrlForVoiceChat,
              child: const Text('Join'),
            ),
          ),
        ),
      ),
    );
  }
}
