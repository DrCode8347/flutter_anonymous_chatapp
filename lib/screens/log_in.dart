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

  // Check if the user name exist in the database and disable button and show error text
  Future<void> checkUsername(String value) async {
    // Query the 'users' table to check if a username exists
    final response = await supabase
        .from('users')
        .select('username')
        .eq('username', value)
        .maybeSingle();

    if (response == null) {
      setState(() {
        disableButton = false;
      });
      print("username available - button disabled? $disableButton");
    } else {
      disableButton = true;
      print("Username already exists - button disabled? $disableButton");
    }
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
                cacheWidth: 200,
              ),
            ),
            // INTO TEXT
            Align(
              child: Text(
                'A N O C H A T',
                style: AppTheme.SubtitleText,
              ),
            ),
            Text(''),
            //USERNAME FIELD
            Text(
              'UserName',
              style: AppTheme.LabelText,
            ),
            CustomTextfield(
              controller: usernameController,
              hintText: 'i.e that dosn\'t relate to you',
              onChange: (value) => checkUsername(value),
            ),
            // Passcode Field
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
                    // set the readonly passphrase field text to a value from generated passphrase
                    setState(() {
                      passphraseController.text = generatePassphrase(32);
                    });
                    // check if all the field are empty and shoe snackbar if they are empty
                    if (usernameController.text.isEmpty &&
                        passphraseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all fields')));
                    }
                  },
                  child: Text(
                    'generate passcode',
                  )),
            ),

            // SIGN IN ANONYMOUSLY
            CustomButton(
                btnName: 'Continue',
                onTap: disableButton
                    ? null
                    : () {
                        // Show the loading screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoadingScreen(
                              message:
                                  "Generating your secure keys. This may take a moment...",
                            ),
                          ),
                        );
                        signInAnonymously(usernameController.text,
                            passphraseController.text, context);
                      }),

            // Anonymity tips and explanations
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => AnonymousTipsPage())),
                  child: Text(
                    'Safety tips',
                  )),
            ),
          ],
        ),
      )),
    );
  }
}
