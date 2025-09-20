import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({Key? key}) : super(key: key);

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final _remoteRenderer = RTCVideoRenderer(); // will hold audio stream too
  bool _inCall = false;

  // configure STUN servers (use public STUN for testing)
  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _endCall();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _startCall() async {
    if (!kIsWeb) {
      await Permission.microphone.request();
    }

    // 1) create pc
    _peerConnection = await createPeerConnection(_config);

    // 2) get local stream and add track
    _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
    _peerConnection?.addStream(_localStream!);

    // 3) when remote stream arrives, set the renderer
    _peerConnection?.onAddStream = (MediaStream stream) {
      print('Remote stream added: ${stream.id}');
      _remoteRenderer.srcObject = stream;
      setState(() {});
    };

    // 4) create offer
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // 5) send offer to the server (replace endpoint with your server)
    final url = Uri.parse('http://127.0.0.1:8000/offer');
    final body = jsonEncode({'sdp': offer.sdp, 'type': offer.type});

    final resp = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(resp.body);
      final answerSdp = data['sdp'];
      final answerType = data['type'];
      await _peerConnection!.setRemoteDescription(RTCSessionDescription(answerSdp, answerType));
      setState(() {
        _inCall = true;
      });
      print("Connected: answer applied");
    } else {
      print("Offer failed: ${resp.statusCode} ${resp.body}");
      // cleanup
      await _endCall();
    }
  }

  Future<void> _endCall() async {
    if (_peerConnection != null) {
      await _peerConnection!.close();
      _peerConnection = null;
    }
    if (_localStream != null) {
      await _localStream!.dispose();
      _localStream = null;
    }
    _remoteRenderer.srcObject = null;
    setState(() {
      _inCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Voice Call Multi-Agent'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _inCall
              ? ElevatedButton.icon(
                  onPressed: _endCall,
                  icon: const Icon(Icons.call_end),
                  label: const Text('End Call'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                )
              : ElevatedButton.icon(
                  onPressed: _startCall,
                  icon: const Icon(Icons.call),
                  label: const Text('Start Call'),
                ),
            const SizedBox(height: 24),
            const Text('Remote audio (played automatically)'),
          ],
        ),
      ),
    );
  }
}
