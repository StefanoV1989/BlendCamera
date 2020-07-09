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
  int numeroScatti = 5;
  

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
                  
                  margin: EdgeInsets.only(bottom: 30),
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: DropdownButton(
                            iconEnabledColor: Colors.transparent,
                            iconDisabledColor: Colors.transparent,
                            isExpanded: true,
                            underline: Container(),
                            dropdownColor: Color.fromRGBO(0, 0, 0, .3),
                            value: numeroScatti,
                            items: [
                              DropdownMenuItem(value: 3, child: Center(child: Text("3 scatti", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)),),
                              DropdownMenuItem(value: 5, child: Center(child: Text("5 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 7, child: Center(child: Text("7 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 10, child: Center(child: Text("10 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 15, child: Center(child: Text("15 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 20, child: Center(child: Text("20 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 25, child: Center(child: Text("25 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 30, child: Center(child: Text("30 scatti", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                              DropdownMenuItem(value: 0, child: Center(child: Text("Illimitato", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                            ],
                            onChanged: (value) {
                              setState(() {
                                numeroScatti = value;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromRGBO(255, 255, 255, .7), width: 2),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: RaisedButton(
                            onPressed: () {
                              catturaFoto(context);
                            },
                            color: Color.fromRGBO(255, 255, 255, .7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: IconButton(
                          color: Colors.transparent,
                          icon: Icon(Icons.switch_camera, color: Color.fromRGBO(255, 255, 255, .7), size: 40,),
                          onPressed: () {
                            print("cambia fotocamera");
                          },
                        ),
                      )
                    ],
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
          builder: (context) => PreviewFoto(immaginiCatturate: immaginiCatturate,)
        )
      );

    } catch(e) {
      print(e);
    }
  }

}