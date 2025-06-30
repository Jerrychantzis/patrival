// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isFinished = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child!),
              (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        alignment: _isFinished ? Alignment.topCenter : Alignment.center,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isFinished ? 0.0 : 1.0,
          child: Image.asset(
            'lib/pictures/logo_edited.png',
            width: 2000, // Ορίζετε το πλάτος της εικόνας
            height: 2000, // Ορίζετε το ύψος της εικόνας
          ),
        ),
      ),
    );
  }
}
