// lib/main_mobile.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'App/Manager.dart';
import 'App/RenovilyApp.dart';
import 'Notification/firebase_options.dart';

Future<void> runAppEntry() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final manager = Manager();
  await manager.autoLoginManager.bootstrap();

  runApp(RenovilyApp(manager: manager));
}
