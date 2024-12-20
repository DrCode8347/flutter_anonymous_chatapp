import 'package:anonymous_chat/components/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anonymous_chat/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openpgp/openpgp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

final FlutterSecureStorage _storage =
    FlutterSecureStorage(aOptions: _getAndroidOptions());
const String _privateKeyStorageKey = 'private_key';

final supabase = Supabase.instance.client;

Future<void> signInAnonymously(
    String userName, String passphrase, BuildContext context) async {
  // sign in the user anonymously
  await supabase.auth.signInAnonymously();

  // generate public and private keys
  await generateKeys(userName, passphrase, context);
}

// ################ GENERATING PRIVATE AND PUBLIC KEYS ##############
Future<void> generateKeys(
    String username, String passphrase, BuildContext context) async {
  // Generate keys
  var keyOptions = KeyOptions()..rsaBits = 4096;
  var keyPair = await OpenPGP.generate(
    options: Options()
      ..name = username
      ..email = username
      ..passphrase = passphrase
      ..keyOptions = keyOptions,
  );

  String privateKey = keyPair.privateKey;
  String publicKey = keyPair.publicKey;

  // Store the private key securely
  await _storage.write(key: _privateKeyStorageKey, value: privateKey);

  // Check if the user is authenticated or if a session is active
  final session = await supabase.auth.currentSession;
  final user = supabase.auth.currentUser;
  if (user != null) {
    // Insert user details into the database
    await supabase.from('users').insert({
      'userid': user.id,
      'username': username,
      'passphrase': passphrase,
      'publickey': publicKey,
    });

    // Store the session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userSession', session!.accessToken);
    
    // Navigate to the homepage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen()), // Ensure HomeScreen is defined
    );
  }
}

// ####################### RESTORE SESSION #######################
// Call this function when your app starts to check for any saved session
Future<void> restoreSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedSession = prefs.getString('userSession');

  if (storedSession != null) {
    // If session exists, set it as the active session
    await supabase.auth.setSession(storedSession);
  } else {
    // Handle case where no session exists (e.g., user needs to sign in)
    // You could redirect to the login page or show a message
  }
}

// ################### RETRIEVING THE PRIVATE KEY SECURELY ##################
Future<String> getPrivateKey() async {
  var privatekey = await _storage.read(key: _privateKeyStorageKey);

  print('this is the private key: $privatekey');
  return privatekey!;
}

// METHOD FOR DECRYPTING MESSAGES RECEIVED
Future<String> decryptMessage(
    SupabaseClient supabase, String userId, String content) async {
  try {
    // FETCH THE USER'S PASSPHRASE FROM THE DATABASE
    final response = await supabase
        .from('users')
        .select('passphrase')
        .eq('userid', userId)
        .maybeSingle();

    if (response == null || response['passphrase'] == null) {
      // HANDLE CASE WHERE PASSPHRASE IS NOT FOUND
      throw Exception('Passphrase not found for user');
    }

    final passphrase = response['passphrase'] as String;

    // FETCH AND AWAIT THE PRIVATE KEY
    final privateKey =
        await getPrivateKey(); // Use `await` if `getPrivateKey` returns a Future

    // DECRYPT THE MESSAGE USING THE PASSPHRASE
    final result = await OpenPGP.decrypt(
      content,
      privateKey,
      passphrase,
    );

    return result;
  } catch (e) {
    // LOG OR HANDLE ERROR AS NEEDED
    print('Decryption failed: $e');
    return '$e';
  }
}

final subscription = supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .order('created_at')
    .listen((List<Map<String, dynamic>> messages) {
      print('New messages: $messages');
    });
