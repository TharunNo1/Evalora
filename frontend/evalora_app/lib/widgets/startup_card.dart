import 'package:flutter/material.dart';
import '../models/startup.dart';

class StartupCard extends StatelessWidget {
  final Startup startup;
  const StartupCard({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startup.idea, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(startup.domain, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Founder',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(startup.founder),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Score', style: Theme.of(context).textTheme.bodySmall),
                    Text(startup.score.toStringAsFixed(0)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
