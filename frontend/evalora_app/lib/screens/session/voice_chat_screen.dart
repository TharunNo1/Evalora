import 'package:flutter/material.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with SingleTickerProviderStateMixin {
  bool listening = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Voice Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text('AI Agent'),
                    const SizedBox(height: 12),
                    // Waveform visualizer (mock)
                    SizedBox(
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return ClipRect(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                40,
                                (i) => Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    child: Container(
                                      height: 10 +
                                          (i % 7) *
                                              (_controller.value * 20),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              listening = !listening;
                            });
                          },
                          icon: Icon(
                              listening ? Icons.mic : Icons.mic_none),
                          iconSize: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Play response'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title:
                        Text('AI: Evaluation will focus on market fit...'),
                  ),
                  ListTile(
                    title: Text(
                        'Founder: We validated in 2 pilot markets...'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
