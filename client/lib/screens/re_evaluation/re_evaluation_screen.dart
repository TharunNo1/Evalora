import 'package:flutter/material.dart';

class ReevaluationDialog {
  /// Shows the Re-evaluation Request Form
  static void show(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController startupController = TextEditingController();
    final TextEditingController ideaIdController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Re-evaluation'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: startupController,
                  decoration: const InputDecoration(
                    labelText: 'Startup Name',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter startup name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ideaIdController,
                  decoration: const InputDecoration(
                    labelText: 'Idea Request ID',
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter idea ID' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Re-evaluation',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter reason' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final String startupName = startupController.text.trim();
                final String ideaId = ideaIdController.text.trim();
                final String reason = reasonController.text.trim();

                // Generate a dummy evaluation ID
                final String evaluationId =
                    'EV-${DateTime.now().millisecondsSinceEpoch}';

                Navigator.of(context).pop(); // Close the form

                // Show confirmation dialog with Evaluation ID
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Request Submitted'),
                    content: Text(
                      'Your re-evaluation request has been submitted successfully.\n\n'
                      'Startup Name: $startupName\n'
                      'Idea Request ID: $ideaId\n'
                      'Evaluation ID: $evaluationId',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
