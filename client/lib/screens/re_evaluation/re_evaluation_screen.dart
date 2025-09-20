import 'package:flutter/material.dart';

class ReEvaluationScreen extends StatefulWidget {
  const ReEvaluationScreen({super.key});

  @override
  State<ReEvaluationScreen> createState() => _ReEvaluationScreenState();
}

class _ReEvaluationScreenState extends State<ReEvaluationScreen> {
  final evalId = TextEditingController();
  final reason = TextEditingController();
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Re-Evaluation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: evalId,
              decoration: const InputDecoration(hintText: 'Evaluation ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reason,
              decoration: const InputDecoration(
                hintText: 'Reason / difficulties',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: sending
                  ? null
                  : () async {
                      setState(() {
                        sending = true;
                      });
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {
                        sending = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Re-evaluation request sent to human agent',
                          ),
                        ),
                      );
                    },
              child: sending
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
