import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String data;

  const ErrorPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(data)));
  }
}
