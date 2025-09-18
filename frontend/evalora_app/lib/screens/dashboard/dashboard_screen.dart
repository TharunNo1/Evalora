import 'package:evalora_app/screens/upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/startup_provider.dart';
// import '../../models/startup.dart';
import '../../widgets/startup_card.dart';
import '../session/session_list_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsAsync = ref.watch(startupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evalora - Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SessionListScreen()),
              );
            },
            icon: const Icon(Icons.schedule),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const UploadScreen()));
            },
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: startupsAsync.when(
          data: (list) => GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) => StartupCard(startup: list[index]),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Failed to load')),
        ),
      ),
    );
  }
}
