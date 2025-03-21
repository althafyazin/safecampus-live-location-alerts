import 'package:flutter/material.dart';

class SupportGroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Groups'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Anti-Ragging Support Group'),
            onTap: () {
              // Join support group
            },
          ),
          // Add more groups as needed
        ],
      ),
    );
  }
}
