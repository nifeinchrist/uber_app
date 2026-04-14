import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uber_app/screens/login_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      // Send user to login screen
      Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/download.jpg", width: 200, height: 200,),
              const SizedBox(height: 10,),
              const Text(
                "Uber & Driver App",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
