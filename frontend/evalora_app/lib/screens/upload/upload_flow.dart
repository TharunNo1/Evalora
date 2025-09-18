import 'package:flutter/material.dart';
import '../../api/mock_service.dart';

class UploadFlow extends StatefulWidget {
  const UploadFlow({super.key});

  @override
  State<UploadFlow> createState() => _UploadFlowState();
}

class _UploadFlowState extends State<UploadFlow> {
  String? requestId;
  bool submitting = false;

  Future<void> submit() async {
    setState(() {
      submitting = true;
    });
    final req = await mockService.submitDocuments('s1');
    setState(() {
      requestId = req.requestId;
      submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Documents')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload founder checklist, pitch deck, and up to 2 optional docs.',
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach files (mock)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submitting ? null : submit,
              child: submitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
            const SizedBox(height: 24),
            if (requestId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Submitted — Request ID: \$requestId'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
