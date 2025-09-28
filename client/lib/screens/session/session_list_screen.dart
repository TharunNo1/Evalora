import 'package:flutter/material.dart';
import 'voicecall_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  Future<void> _openUrlForVoiceChat(String requestID) async {
    var url = 'https://evalorasession.web.app/?requestID='+requestID;

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Evaluation Sessions'),
  //       backgroundColor: Colors.blueGrey.shade900,
  //     ),
  //     body: ListView.builder(
  //       padding: const EdgeInsets.all(16),
  //       itemCount: 4,
  //       itemBuilder: (context, i) => Card(
  //         child: ListTile(
  //           title: Text('Session with Evaluator #\$i'),
  //           subtitle: const Text('AI-assisted voice session scheduled'),
  //           trailing: ElevatedButton(
  //             onPressed: _openUrlForVoiceChat,
  //             child: const Text('Join'),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

@override
  Widget build(BuildContext context) {
    final sessions = [
  {
    'startupName': 'DataStride AI',
    'requestID': 'REQ-1001',
    'time': 'Sep 22, 2025 • 10:00 AM',
    'status': 'Scheduled',
  },
  {
    'startupName': 'GreenWave Solutions',
    'requestID': 'REQ-1002',
    'time': 'Sep 22, 2025 • 02:00 PM',
    'status': 'Scheduled',
  },
  {
    'startupName': 'NeuroBotics',
    'requestID': 'REQ-1003',
    'time': 'Sep 23, 2025 • 11:00 AM',
    'status': 'Completed',
  },
  {
    'startupName': 'FinEdge',
    'requestID': 'REQ-1004',
    'time': 'Sep 23, 2025 • 03:00 PM',
    'status': 'Scheduled',
  },
  {
    'startupName': 'EcoCharge',
    'requestID': 'REQ-1005',
    'time': 'Sep 24, 2025 • 09:30 AM',
    'status': 'Scheduled',
  },
  {
    'startupName': 'HealthPulse',
    'requestID': 'REQ-1006',
    'time': 'Sep 24, 2025 • 01:00 PM',
    'status': 'Completed',
  },
  {
    'startupName': 'RoboLogix',
    'requestID': 'REQ-1007',
    'time': 'Sep 25, 2025 • 10:30 AM',
    'status': 'Scheduled',
  },
  {
    'startupName': 'SmartAgro',
    'requestID': 'REQ-1008',
    'time': 'Sep 25, 2025 • 02:30 PM',
    'status': 'Scheduled',
  },
];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Sessions'),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, i) {
          final session = sessions[i];
          final status = session['status']!;
          final isScheduled = status == 'Scheduled';

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              leading: CircleAvatar(
                // backgroundImage: AssetImage('assets/evaluator${i + 1}.png'),
              ),
              title: Text(session['startupName']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session['requestID']!),
                  const SizedBox(height: 4),
                  Text(
                    session['time']!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isScheduled ? Colors.cyan : Colors.green),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isScheduled ? Colors.blueAccent : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isScheduled ?  () => _openUrlForVoiceChat(session['requestID'].toString()) : null,
                child: Text(isScheduled ? 'Join' : 'Done',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}
