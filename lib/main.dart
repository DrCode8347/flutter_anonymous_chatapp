import 'package:anonymous_chat/screens/splash_screen.dart';
import 'package:anonymous_chat/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ducydehduxkaybbzdkhn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1Y3lkZWhkdXhrYXliYnpka2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE2Nzg3MzYsImV4cCI6MjA0NzI1NDczNn0.hxsW7MEfWmxBGcgyL32nXnjaPRLLitYSMpcpofxoqg0',
    realtimeClientOptions: RealtimeClientOptions(
      timeout: Duration(milliseconds: 30000), // Set timeout to 30 seconds
    ),
  );

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
