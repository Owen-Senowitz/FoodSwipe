import 'package:flutter/material.dart';

class LoginScaffold extends StatelessWidget {
  final Widget child;
  final String path;

  const LoginScaffold({required this.child, required this.path, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true, body: child);
  }
}
