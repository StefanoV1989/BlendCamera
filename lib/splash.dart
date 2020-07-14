import 'dart:ui';

import 'package:blendcamera/fotocamera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {

  

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    Size size = MediaQuery.of(context).size;

    //Offset center = Offset(size.width / 2, size.height / 2);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(
             MaterialPageRoute(
              builder: (context) => Fotocamera()
            )
          );
        },
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0), 
                  radius: .8,
                  colors: [
                    const Color(0xFF62d1e2), // yellow sun
                    const Color(0xFFf0dbf0), // blue sky
                  ],
                  stops: [0.4, 1.0],
                )
              ),
              child: 
                  FractionallySizedBox(
                    child: Image(image: AssetImage("images/logo.png")),
                    widthFactor: .7,
                  ),
                  
                
            ),
            Container(
              margin: EdgeInsets.only(bottom: 50),
              alignment: Alignment.bottomCenter,
              child: Text("Tap to continue ...", style: TextStyle(fontWeight: FontWeight.bold),),
            )
          ],
        ),
      ),
    );
  }
}