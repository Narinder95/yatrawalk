import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionTest extends StatefulWidget {
  const PermissionTest({super.key});

  @override
  State<PermissionTest> createState() => _PermissionTestState();
}

class _PermissionTestState extends State<PermissionTest> {
  String status = "Checking...";

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    final before = await Permission.activityRecognition.status;

    final after = await Permission.activityRecognition.request();

    setState(() {
      status = "Before: $before\nAfter: $after";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permission Test")),
      body: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}