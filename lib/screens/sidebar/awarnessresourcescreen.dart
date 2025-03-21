import 'package:flutter/material.dart';

class AwarenessResourcesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Awareness Resources'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Anti-Ragging Laws'),
            onTap: () {
              // Open link or document
            },
          ),
          ListTile(
            title: Text('Success Stories'),
            onTap: () {
              // Open link or document
            },
          ),
          // Add more resources as needed
        ],
      ),
    );
  }
}
