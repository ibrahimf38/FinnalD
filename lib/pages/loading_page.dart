import 'package:MaliDiscover/pages/acceil_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class MyloadingPage extends StatefulWidget {
  const MyloadingPage({super.key, required this.title});

  final String title;

  @override
  State<MyloadingPage> createState() => _MyloadingPageState();
}

class _MyloadingPageState extends State<MyloadingPage> {

  @override
  void initState() {
    super.initState();
    loadAnimation();
  }

  Future<Timer> loadAnimation() async {
    return Timer(const Duration(seconds: 5), onloaded);
  }

  onloaded() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
      builder: (context) => AcceilPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Lottie.asset("assets/lotties/discover.json")),
    );
  }
 @override
 void inistate() {
  super.initState();
  Future.delayed(Duration(seconds: 4), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AcceilPage()),
    );
  });
}
}
