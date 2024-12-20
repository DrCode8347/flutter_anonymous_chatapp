import 'package:anonymous_chat/screens/homescreen.dart'; // Import your HomeScreen
import 'package:anonymous_chat/screens/log_in.dart'; // Import your LogIn page
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ####################### SECTION - FUNCTIONS ####################### //

  @override
  void initState() {
    super.initState();
    routeToNextScreen(); // Check session and route accordingly
  }

  // Function to check session and route accordingly
  routeToNextScreen() async {
    // Get the stored session from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedSession = prefs.getString('userSession');

    // Check for current Supabase session
    final session = Supabase.instance.client.auth.currentSession;

    await Future.delayed(
        Duration(seconds: 2)); // Simulate splash screen loading time

    // If either session exists (stored or Supabase session), navigate to home page
    if (session != null || storedSession != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => HomeScreen(), // Navigate to your HomeScreen
        ),
      );
    } else {
      // If no session, navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => LogIn(), // Navigate to your LogIn page
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash screen image and app logo
            Image.asset(
              'assets/images/splashIcon.png',
              cacheWidth: 200,
            ),
            // App Name
            Text('A N O C H A T'),
          ],
        ),
      ),
    );
  }
}
