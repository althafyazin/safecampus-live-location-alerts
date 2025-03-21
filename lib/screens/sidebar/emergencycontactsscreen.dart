import 'package:flutter/material.dart';

class EmergencyContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.local_police),
            title: Text('Local Police'),
            subtitle: Text('Call: 100'),
            trailing: IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                // Call local police
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Ambulance'),
            subtitle: Text('Call: 108'),
            trailing: IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                // Call ambulance
              },
            ),
          ),
          // Add more contacts as needed
        ],
      ),
    );
  }
}
