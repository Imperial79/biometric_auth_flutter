import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class AuthUI extends StatefulWidget {
  const AuthUI({super.key});

  @override
  State<AuthUI> createState() => _AuthUIState();
}

class _AuthUIState extends State<AuthUI> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometric = false;
  List<BiometricType> _availableBiometric = [];

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref().child('count');
    _testRef.onValue.listen((event) {
      setState(() {
        value = event.snapshot.value.toString();
      });
    });
  }

  String value = "0";

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });

    if (_canCheckBiometric)
      _getAvailableBiometric();
    else {
      print("Hardware not supported");
    }
  }

  Future _getAvailableBiometric() async {
    List<BiometricType> availableBiometric = [];

    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometric = availableBiometric;
      log("Available Biometric: " + _availableBiometric.toString());
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: "Scan your finger to authenticate",
        // useErrorDialogs: true,
        // stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }
    setState(() {
      String authorized =
          authenticated ? "Authorized success" : "Failed to authenticate";
      print("Authorized: " + authorized);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$value'),
            ElevatedButton(
                onPressed: () {
                  _init();
                },
                child: Text("Set"))
          ],
        ),
      ),
    );
  }
}
