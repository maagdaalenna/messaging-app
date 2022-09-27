import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messaging_app/messaging_app.dart';

Future<void> main() async {
  // firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // get_it package for registering singletons
  GetIt.I.registerLazySingleton(() => FirebaseAuth.instance);

  runApp(MessagingApp());
}
