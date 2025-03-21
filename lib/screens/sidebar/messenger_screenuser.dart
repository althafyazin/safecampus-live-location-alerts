import 'package:flutter/material.dart';

class MessengerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Admin'),
            subtitle: Text('Last message: Hello!'),
            onTap: () {
              // Navigate to chat screen with admin
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(recipient: 'Admin')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String recipient;

  ChatScreen({required this.recipient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipient),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Chat messages go here
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Send message logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
