// lib/Auth/Shared/nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void goAfterFrame(BuildContext context, String location) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.go(location);
  });
}

void goNamedAfterFrame(BuildContext context, String name) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.goNamed(name);
  });
}
