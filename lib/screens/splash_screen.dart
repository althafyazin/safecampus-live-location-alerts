import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image.asset(
                  'assets/images/ANTI-RAGGING.png',
                  width: 150,
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "ANTI - RAGGING",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 144, 136, 136),
                  fontFamily: 'Times New Roman',
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(delay: 0),
                  _buildDot(delay: 0.2),
                  _buildDot(delay: 0.4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({double delay = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 144, 136, 136),
          shape: BoxShape.circle,
        ),
        curve: Curves.easeInOut,
        child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(),
        ),
      ),
    );
  }
}
