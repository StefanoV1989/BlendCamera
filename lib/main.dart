
import 'package:blendcamera/splash.dart';
import 'package:flutter/material.dart';

void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlendCamera',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
      
    );
  }
}



