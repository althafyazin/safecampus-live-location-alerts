import 'package:antiragging1/screens/admin_homepage.dart';
import 'package:antiragging1/screens/login_screen.dart';
import 'package:antiragging1/screens/signuppage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:antiragging1/models/student.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antiragging1/screens/homepage.dart';
import 'package:antiragging1/screens/splash_screen.dart'; // Import the SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register the adapter first
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(StudentAdapter());
  }
  // Open the Hive box
  await Hive.openBox<Student>('students');

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Debug print to check students
  final studentBox = Hive.box<Student>('students');
  print('Number of students: ${studentBox.length}');
  print('All students: ${studentBox.values.toList()}');

  runApp(MyApp(
    initialRoute:
        isLoggedIn ? '/home' : '/splash', // Set initial route to SplashScreen
  ));
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
      initialRoute: widget.initialRoute,
      routes: {
        '/splash': (context) => SplashScreen(), // Add SplashScreen route
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/adminHome': (context) => AdminHomePage(),
      },
    );
  }
}
