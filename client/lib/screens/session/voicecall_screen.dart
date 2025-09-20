// import 'package:flutter/material.dart';

// class VoiceCallScreen extends StatefulWidget {
//   const VoiceCallScreen({super.key});

//   @override
//   State<VoiceCallScreen> createState() => _VoiceCallScreenState();
// }

// class _VoiceCallScreenState extends State<VoiceCallScreen>
//     with SingleTickerProviderStateMixin {
//   bool listening = false;
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AI Voice Session')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   children: [
//                     const Text('AI Agent'),
//                     const SizedBox(height: 12),
//                     // Waveform visualizer (mock)
//                     SizedBox(
//                       height: 80,
//                       child: AnimatedBuilder(
//                         animation: _controller,
//                         builder: (context, child) {
//                           return ClipRect(
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: List.generate(
//                                 40,
//                                 (i) => Flexible(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 1),
//                                     child: Container(
//                                       height: 10 +
//                                           (i % 7) *
//                                               (_controller.value * 20),
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .primary,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               listening = !listening;
//                             });
//                           },
//                           icon: Icon(
//                               listening ? Icons.mic : Icons.mic_none),
//                           iconSize: 36,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                         const SizedBox(width: 12),
//                         ElevatedButton(
//                           onPressed: () {},
//                           child: const Text('Play response'),
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: const [
//                   ListTile(
//                     title:
//                         Text('AI: Evaluation will focus on market fit...'),
//                   ),
//                   ListTile(
//                     title: Text(
//                         'Founder: We validated in 2 pilot markets...'),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:web_socket_channel/io.dart';

// class VoiceCallScreen extends StatefulWidget {
//   @override
//   _VoiceCallScreenState createState() => _VoiceCallScreenState();
// }

// class _VoiceCallScreenState extends State<VoiceCallScreen>
//     with SingleTickerProviderStateMixin {
//   // Audio
//   FlutterSoundRecorder? _recorder;
//   bool isRecording = false;

//   // WebSocket
//   late IOWebSocketChannel channel;
//   bool isConnected = false;

//   // Transcript
//   List<Map<String, String>> messages = [];
//   // Audio stream
//   late StreamController<Uint8List> _audioStreamController;
//   // Wave animation
//   late AnimationController _waveController;

//   @override
//   void initState() {
//     super.initState();
//     _waveController =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 1200))
//           ..repeat();
//     _audioStreamController = StreamController<Uint8List>();
//     _initRecorder();
//     _connectWebSocket();
//   }

//   @override
//   void dispose() {
//     _waveController.dispose();
//     _recorder?.closeRecorder();
//     if (isConnected) channel.sink.close();
//     super.dispose();
//   }

//   Future<void> _initRecorder() async {
//     _recorder = FlutterSoundRecorder();
//     await _recorder!.openRecorder();
//     await Permission.microphone.request();
//   }

//   void _connectWebSocket() {
//     try {
//       channel = IOWebSocketChannel.connect('ws://localhost:8080');
//       isConnected = true;

//       channel.stream.listen((event) {
//         final data = jsonDecode(event);
//         if (data['type'] == 'user_transcript') {
//           _updateTranscript(data['text'], 'user', partial: true);
//         } else if (data['type'] == 'assistant_text') {
//           _updateTranscript(data['text'], 'assistant', partial: true);
//         } else if (data['type'] == 'turn_complete') {
//           // mark last assistant message as complete
//           if (messages.isNotEmpty && messages.last['sender'] == 'assistant') {
//             messages.last.remove('partial');
//             setState(() {});
//           }
//         }
//       }, onError: (err) {
//         _updateTranscript("WebSocket error: $err", 'system');
//       }, onDone: () {
//         isConnected = false;
//       });
//     } catch (e) {
//       _updateTranscript("Failed to connect to server", 'system');
//     }
//   }

//   void _updateTranscript(String text, String sender, {bool partial = false}) {
//     setState(() {
//       if (partial &&
//           messages.isNotEmpty &&
//           messages.last['sender'] == sender &&
//           messages.last.containsKey('partial')) {
//         messages.last['text'] = text;
//       } else {
//         messages.add({'sender': sender, 'text': text, if (partial) 'partial': 'true'});
//       }
//     });
//   }

//   void _toggleRecording() async {
//     if (!isConnected) return;

//     if (isRecording) {
//       await _recorder!.stopRecorder();
//       setState(() => isRecording = false);
//       channel.sink.add(jsonEncode({'type': 'stop_recording'}));
//     } else {
//       final path = await _recorder!.startRecorder(
//         toStream: _audioStreamController.sink,
//         codec: Codec.pcm16,
//       );
//       setState(() => isRecording = true);
//     }
//   }

//   Widget buildWave() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(5, (index) {
//         return AnimatedBuilder(
//           animation: _waveController,
//           builder: (_, child) {
//             double scaleY = 0.4 +
//                 0.6 *
//                     (0.5 *
//                         (1 + sin((_waveController.value * 2 * pi) +
//                             index * 0.2)));
//             return Container(
//               width: 4,
//               height: 24 * scaleY,
//               margin: EdgeInsets.symmetric(horizontal: 2),
//               decoration: BoxDecoration(
//                 color: Color(0xFF4285F4),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           children: [
//             RichText(
//               text: TextSpan(
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 children: [
//                   TextSpan(text: 'E', style: TextStyle(color: Color(0xFF4285F4))),
//                   TextSpan(text: 'v', style: TextStyle(color: Color(0xFFDB4437))),
//                   TextSpan(text: 'a', style: TextStyle(color: Color(0xFFF4B400))),
//                   TextSpan(text: 'l', style: TextStyle(color: Color(0xFF4285F4))),
//                   TextSpan(text: 'o', style: TextStyle(color: Color(0xFF0F9D58))),
//                   TextSpan(text: 'r', style: TextStyle(color: Color(0xFFDB4437))),
//                   TextSpan(text: 'a', style: TextStyle(color: Colors.black)),
//                 ],
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               "Personal AI Assistant",
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             )
//           ],
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 4,
//         systemOverlayStyle:
//             SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
//                   ],
//                 ),
//                 padding: EdgeInsets.all(16),
//                 child: messages.isEmpty
//                     ? Center(
//                         child: Text(
//                           "Start a conversation to see the transcript.",
//                           style: TextStyle(color: Colors.grey[500]),
//                         ),
//                       )
//                     : ListView.builder(
//                         reverse: true,
//                         itemCount: messages.length,
//                         itemBuilder: (context, index) {
//                           final message = messages[messages.length - 1 - index];
//                           bool isUser = message['sender'] == 'user';
//                           bool isSystem = message['sender'] == 'system';
//                           return Container(
//                             alignment: isUser
//                                 ? Alignment.centerRight
//                                 : isSystem
//                                     ? Alignment.center
//                                     : Alignment.centerLeft,
//                             margin: EdgeInsets.symmetric(vertical: 4),
//                             child: Container(
//                               padding: EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: isUser
//                                     ? Colors.blue[100]
//                                     : isSystem
//                                         ? Colors.grey[300]
//                                         : Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 message['text'] ?? '',
//                                 style: TextStyle(
//                                   color: isUser
//                                       ? Colors.blue[900]
//                                       : Colors.black87,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ),
//             if (isRecording)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12.0),
//                 child: buildWave(),
//               ),
//             SizedBox(height: 12),
//             Column(
//               children: [
//                 GestureDetector(
//                   onTap: _toggleRecording,
//                   child: Container(
//                     width: 64,
//                     height: 64,
//                     decoration: BoxDecoration(
//                       color: isRecording ? Color(0xFFDB4437) : Color(0xFF4285F4),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: isRecording ? 8 : 4,
//                             offset: Offset(0, isRecording ? 4 : 2))
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.mic,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   isRecording
//                       ? "Recording..."
//                       : "Click the icon to start recording",
//                   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:math';
// ignore: deprecated_member_use
import 'dart:html' as html; // For Web microphone
import 'dart:typed_data' show Uint8List, ByteBuffer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:web_socket_channel/html.dart'; // WebSocket for Web

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  // Web microphone
  html.MediaStream? _localStream;
  html.MediaRecorder? _mediaRecorder;
  bool isRecording = false;

  // WebSocket
  late HtmlWebSocketChannel channel;
  bool isConnected = false;

  // Transcript
  List<Map<String, String>> messages = [];

  // Wave animation
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _waveController.dispose();
    stopRecording();
    if (isConnected) channel.sink.close();
    super.dispose();
  }

  void _connectWebSocket() {
    try {
      channel = HtmlWebSocketChannel.connect('ws://localhost:8000/ws/stream');
      isConnected = true;

      channel.stream.listen(
        (event) {
          final data = jsonDecode(event);
          if (data['type'] == 'user_transcript') {
            _updateTranscript(data['text'], 'user', partial: true);
          } else if (data['type'] == 'assistant_text') {
            _updateTranscript(data['text'], 'assistant', partial: true);
          } else if (data['type'] == 'turn_complete') {
            if (messages.isNotEmpty && messages.last['sender'] == 'assistant') {
              messages.last.remove('partial');
              setState(() {});
            }
          }
        },
        onError: (err) {
          _updateTranscript("WebSocket error: $err", 'system');
        },
        onDone: () {
          isConnected = false;
        },
      );
    } catch (e) {
      _updateTranscript("Failed to connect to server", 'system');
    }
  }

  void _updateTranscript(String text, String sender, {bool partial = false}) {
    setState(() {
      if (partial &&
          messages.isNotEmpty &&
          messages.last['sender'] == sender &&
          messages.last.containsKey('partial')) {
        messages.last['text'] = text;
      } else {
        messages.add({
          'sender': sender,
          'text': text,
          if (partial) 'partial': 'true',
        });
      }
    });
  }

  Future<void> startRecording() async {
    if (!isConnected) return;

    // Request microphone access
    _localStream = await html.window.navigator.mediaDevices!.getUserMedia({
      'audio': true,
      'video': false,
    });

    _mediaRecorder = html.MediaRecorder(_localStream!);

    // Register event using .addEventListener
    _mediaRecorder!.addEventListener('dataavailable', (event) {
      final blobEvent = event as html.BlobEvent;
      final blob = blobEvent.data;
      if (blob != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        reader.onLoadEnd.listen((_) {
          final buffer = reader.result as ByteBuffer;
          final bytes = Uint8List.view(buffer);
          final base64Data = base64Encode(bytes);
          if (isConnected) {
            channel.sink.add(jsonEncode({'type': 'audio', 'data': base64Data}));
          }
        });
      }
    });

    _mediaRecorder!.start();
    setState(() => isRecording = true);
  }

  void stopRecording() {
    if (_mediaRecorder != null && _mediaRecorder!.state == "recording") {
      _mediaRecorder!.stop();
    }
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream = null;
    setState(() => isRecording = false);

    if (isConnected) {
      channel.sink.add(jsonEncode({'type': 'stop_recording'}));
    }
  }

  void _toggleRecording() {
    if (isRecording) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  Widget buildWave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _waveController,
          builder: (_, child) {
            double scaleY =
                0.4 +
                0.6 *
                    (0.5 *
                        (1 +
                            sin(
                              (_waveController.value * 2 * pi) + index * 0.2,
                            )));
            return Container(
              width: 4,
              height: 24 * scaleY,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Color(0xFF4285F4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Evalora',
                    style: TextStyle(color: Color.fromARGB(255, 230, 233, 237)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Startup Evaluator",
              style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 217, 204, 204)),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          "Start a conversation to see the transcript.",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];
                          bool isUser = message['sender'] == 'user';
                          bool isSystem = message['sender'] == 'system';
                          return Container(
                            alignment: isUser
                                ? Alignment.centerRight
                                : isSystem
                                ? Alignment.center
                                : Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue[100]
                                    : isSystem
                                    ? Colors.grey[300]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: TextStyle(
                                  color: isUser
                                      ? Colors.blue[900]
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            if (isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: buildWave(),
              ),
            SizedBox(height: 12),
            Column(
              children: [
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Color(0xFFDB4437)
                          : Color(0xFF4285F4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: isRecording ? 8 : 4,
                          offset: Offset(0, isRecording ? 4 : 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.mic, color: Colors.white, size: 32),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  isRecording
                      ? "Recording..."
                      : "Click the icon to start recording",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
