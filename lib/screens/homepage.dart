import 'package:antiragging1/screens/sidebar/awarnessresourcescreen.dart';
import 'package:antiragging1/screens/sidebar/chatbotscreen.dart';
import 'package:antiragging1/screens/sidebar/emergencycontactsscreen.dart';
import 'package:antiragging1/screens/sidebar/feedbackcomplaintboxscreen.dart';
import 'package:antiragging1/screens/sidebar/incedentreportingscreen.dart';
import 'package:antiragging1/screens/sidebar/messenger_screenuser.dart';
import 'package:antiragging1/screens/sidebar/selfdefencetipscreen.dart';
import 'package:antiragging1/screens/sidebar/settingsscreen.dart';
import 'package:antiragging1/screens/sidebar/supportgrpsscreen.dart';
import 'package:flutter/material.dart';
import 'audio_screen.dart';
import 'location_screen.dart';
import 'profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    AudioStreamScreen(),
    LocationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anti-Ragging Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear all stored preferences
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Anti-Ragging App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Messenger'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessengerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble),
              title: const Text('Anti-Ragging Chatbot'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emergency),
              title: const Text('Emergency Contacts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmergencyContactsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Incident'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IncidentReportingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Awareness Resources'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AwarenessResourcesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: const Text('Self-Defense Tips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelfDefenseTipsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Support Groups'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SupportGroupsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback/Complaint Box'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.audio_file),
            label: 'Audio',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.green,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlue,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
