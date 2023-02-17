import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Fam.ly/messaging_app.dart';

Future<void> main() async {
  // firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MessagingApp());
}

// To build app-release.apk open Terminal and write:
// flutter build apk --release
