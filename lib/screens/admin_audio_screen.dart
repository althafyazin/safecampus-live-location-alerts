import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';

class AdminAudioScreen extends StatefulWidget {
  @override
  _AdminAudioScreenState createState() => _AdminAudioScreenState();
}

class _AdminAudioScreenState extends State<AdminAudioScreen> {
  IO.Socket? _socket;
  List<Map<String, dynamic>> _audioDataList = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    _socket = IO.io('http://your-server-ip:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket!.onConnect((_) {
      print('Connected to server');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
    });

    _socket!.on('audioStream', (data) {
      setState(() {
        _audioDataList.add(data);
      });
    });
  }

  void _playAudio(String audioData) async {
    final bytes = base64Decode(audioData);

    await _audioPlayer.play(BytesSource(bytes));
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Audio Panel"),
      ),
      body: _audioDataList.isEmpty
          ? Center(child: Text("No audio data available"))
          : ListView.builder(
              itemCount: _audioDataList.length,
              itemBuilder: (context, index) {
                final audioData = _audioDataList[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("Name: ${audioData['name']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Admission Number: ${audioData['admissionNumber']}"),
                        Text("Phone Number: ${audioData['phoneNumber']}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        _playAudio(audioData['audioData']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
