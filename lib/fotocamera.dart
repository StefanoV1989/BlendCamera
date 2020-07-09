import 'dart:io';

import 'package:blendcamera/preview.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Fotocamera extends StatefulWidget {
  @override
  _FotocameraState createState() => _FotocameraState();
}

class _FotocameraState extends State<Fotocamera> {

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  bool isCameraReady = false;
  bool stopCamera = false;
  List<String> immaginiCatturate;
  int numeroScatti = 3;
  

  @override
  void initState() {
    super.initState();
    
    _inizializzaCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    double deviceRatio = size.width / size.height;

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if(orientation == Orientation.portrait)
          {
            return Stack(
              children: <Widget>[
                Container(
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.done)
                      {
                        return Transform.scale(
                          scale: _controller.value.aspectRatio / deviceRatio,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: CameraPreview(_controller),
                            ),
                          ),
                        );
                      }
                      else 
                      {
                        return Center(child: CircularProgressIndicator(),);
                      }
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                    onPressed: () {
                      print("TEST");
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                    ),
                  ),
                )
              ],
            );
          }
          else
          {
            return Text("LANDSCAPE");
          }
        },
      ),
    );
  }

  Future<void> _inizializzaCamera() async  {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription firstCamera = cameras.first;
    
    _controller = CameraController(firstCamera, ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();

    if(!mounted)
    {
      return;
    }

    setState(() {
      isCameraReady = true;
    });

  }

  void didChangeAppLifecycleState(AppLifecycleState state)
  {
    if(state == AppLifecycleState.resumed)
    {
      // ignore: unnecessary_statements
      _controller != null ? _initializeControllerFuture = _controller.initialize() : null;
    }
  }

  void catturaFoto(BuildContext context) async {
    try {
      
      for(int i = 0; i<numeroScatti; i++)
      {
        String path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

        immaginiCatturate.add(path);

        await _controller.takePicture(path);

        // 200 millisecondi di delay
        sleep(Duration(milliseconds: 200));

        if(stopCamera)
        {
          break;
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewFoto()
        )
      );

    } catch(e) {
      print(e);
    }
  }

}