import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: false, // Replace with actual state
            onChanged: (value) {
              // Toggle dark mode
            },
          ),
          // Add more settings as needed
        ],
      ),
    );
  }
}
