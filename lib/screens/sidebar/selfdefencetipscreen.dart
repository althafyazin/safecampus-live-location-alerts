import 'package:flutter/material.dart';

class SelfDefenseTipsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Self-Defense Tips'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Basic Self-Defense Techniques'),
            onTap: () {
              // Open tutorial or video
            },
          ),
          ListTile(
            title: Text('How to Stay Safe'),
            onTap: () {
              // Open tutorial or video
            },
          ),
          // Add more tips as needed
        ],
      ),
    );
  }
}
