import 'dart:math';

import 'package:anonymous_chat/components/custom_button.dart';
import 'package:anonymous_chat/components/custom_textfield.dart';
import 'package:anonymous_chat/components/loading_screen.dart';
import 'package:anonymous_chat/components/start_tips.dart';
import 'package:anonymous_chat/utils/queries.dart';
import 'package:anonymous_chat/utils/theme.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // #################### SECTION - VARIABLE DECLARATION #################### //

  TextEditingController usernameController = TextEditingController();
  TextEditingController passphraseController = TextEditingController();
  bool disableButton = true;

  // ######################### SECTION - FUNCTIONS ##########################//
  // Generate passphrase
  String generatePassphrase(int length) {
    // CHARACTER SETS
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = r'!@#\$%^&*()-_=+<>?';
    // COMBINING ALL CHARACTERS
    const String allChars = upperCase + lowerCase + numbers + symbols;
    // INITIALIZING RANDOM GENERATOR
    final Random random = Random();
    // GENERATING PASSPHRASE
    return List.generate(
        length, (index) => allChars[random.nextInt(allChars.length)]).join();
  }

  // Check if the username exists in the database
  Future<bool> doesUsernameExist(String value) async {
    try {
      final response = await supabase
          .from('users')
          .select('username')
          .eq('username', value)
          .maybeSingle();

      return response != null; // Return true if username exists
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking username: $e')),
      );
      return false; // Assume username does not exist in case of error
    }
  }

  // Perform sign-in
  Future<void> performSignIn() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingScreen(
          message: "Generating your secure keys. This may take a moment...",
        ),
      ),
    );

    await signInAnonymously(
        usernameController.text, passphraseController.text, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO IMAGE
              Align(
                child: Image.asset(
                  'assets/images/splashIcon.png',
                  width: 200,
                ),
              ),
              // INTRO TEXT
              Align(
                child: Text(
                  'A N O C H A T',
                  style: AppTheme.SubtitleText,
                ),
              ),
              const SizedBox(height: 8.0),
              // USERNAME FIELD
              Text(
                'UserName',
                style: AppTheme.LabelText,
              ),
              CustomTextfield(
                controller: usernameController,
                hintText: 'i.e that doesn\'t relate to you',
              ),
              // PASSPHRASE FIELD
              Text(
                'Passphrase',
                style: AppTheme.LabelText,
              ),
              CustomTextfield(
                controller: passphraseController,
                hintText: 'press generate passphrase',
                readOnly: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Generate passphrase
                    setState(() {
                      passphraseController.text = generatePassphrase(32);
                    });

                    // Check if all fields are empty and show snackbar if they are
                    if (usernameController.text.isEmpty &&
                        passphraseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                    }
                  },
                  child: const Text('generate passcode'),
                ),
              ),
              // CONTINUE BUTTON
              CustomButton(
                btnName: 'Continue',
                onTap: () async {
                  final usernameExists =
                      await doesUsernameExist(usernameController.text);

                  if (usernameExists) {
                    // Show error snackbar if username exists
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Username already exists. Please try another.'),
                      ),
                    );
                  } else {
                    // Proceed with sign-in and routing
                    await performSignIn();
                  }
                },
              ),
              // ANONYMITY TIPS
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => AnonymousTipsPage()),
                  ),
                  child: const Text('Safety tips'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
