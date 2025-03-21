import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Location Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Add location tracking logic here
              },
              icon: Icon(Icons.my_location),
              label: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
