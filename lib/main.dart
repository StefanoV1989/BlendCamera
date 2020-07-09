import 'package:blendcamera/fotocamera.dart';
import 'package:flutter/material.dart';

void main() {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlendCamera',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Fotocamera(),
      
    );
  }
}



