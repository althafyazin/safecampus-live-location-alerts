import 'package:flutter/material.dart';

class ChatbotScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anti-Ragging Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Chatbot messages go here
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
                      hintText: 'Ask a question...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Send question to chatbot
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
