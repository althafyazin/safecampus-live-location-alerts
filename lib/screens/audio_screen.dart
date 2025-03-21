import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path_provider/path_provider.dart'; // For getting the app's directory
import 'admin_audio_screen.dart'; // Import the AdminAudioScreen

class AudioStreamScreen extends StatefulWidget {
  @override
  _AudioStreamScreenState createState() => _AudioStreamScreenState();
}

class _AudioStreamScreenState extends State<AudioStreamScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  IO.Socket? _socket;
  bool _isRecording = false;
  String? _recordingPath; // Store the path of the recording

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    // Connect to the Socket.IO server
    _socket = IO.io('http://your-server-ip:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket!.onConnect((_) {
      print('Connected to server');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  Future<void> _startRecording() async {
    // Check for microphone permission
    final bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      print('Microphone permission denied');
      return;
    }

    // Get the app's documents directory to save the recording
    final directory = await getApplicationDocumentsDirectory();
    final String recordingPath = '${directory.path}/recording.m4a';

    // Start recording with proper configuration
    await _audioRecorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc, // Use AAC codec for better compatibility
        bitRate: 128000, // Set bitrate (128 kbps)
        sampleRate: 44100, // Set sample rate (44.1 kHz)
      ),
      path: recordingPath, // Provide a valid file path
    );

    setState(() {
      _isRecording = true;
      _recordingPath = recordingPath; // Store the recording path
    });

    // Listen for audio data and send it to the server with client details
    _audioRecorder.onAmplitudeChanged((amplitude) {
      // Send audio data and client details to the server
      _socket!.emit('audioStream', {
        'audioData': amplitude,
        'name': 'John Doe', // Replace with actual client name
        'admissionNumber': '12345678', // Replace with actual admission number
        'phoneNumber': '+1234567890', // Replace with actual phone number
      });
    } as Duration);
  }

  Future<void> _stopRecording() async {
    // Stop recording
    await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });

    // Print the path of the saved recording
    if (_recordingPath != null) {
      print('Recording saved at: $_recordingPath');
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose(); // Dispose of the recorder
    _socket?.disconnect(); // Disconnect from the server
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Stream"),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              // Navigate to the AdminAudioScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminAudioScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording
                  ? null
                  : _startRecording, // Disable if already recording
              child: Text("Start Recording"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording
                  ? _stopRecording
                  : null, // Disable if not recording
              child: Text("Stop Recording"),
            ),
            SizedBox(height: 20),
            Text(_isRecording ? "Recording..." : "Press to start recording"),
          ],
        ),
      ),
    );
  }
}
