import 'package:anonymous_chat/screens/log_in.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
// ####################### SECTION - FUNCTIONS ####################### //
  @override
  void initState() {
    //run route to log in upon build of this page
    routeToLogin();

    super.initState();
  }

  // Route to log in screen
  routeToLogin() {
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => LogIn()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash screen image and also app logo
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
