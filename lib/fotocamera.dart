

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blendcamera/preview.dart';

class Fotocamera extends StatefulWidget {
  @override
  _FotocameraState createState() => _FotocameraState();
}

class _FotocameraState extends State<Fotocamera> {

  

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  bool isCameraReady = false;
  bool stopCamera = false;
  bool scattando = false;
  
  int numeroScatti = 5;
  double progress = 0.00;

  @override
  void initState() {
    super.initState();

    //SystemChrome.setEnabledSystemUIOverlays([]);
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); // toglie fullscreen
    
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

    return SafeArea(
      child: Scaffold(
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

                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: SizedBox(
                                width: 62,
                                height: 62,
                                child: CircularProgressIndicator(
                                  value: progress,
                                )
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
                                    
                                    
                                    if(!scattando)
                                    {
                                      setState(() {
                                        scattando = true;
                                      });

                                      catturaFoto(context);
                                    }
                                    else
                                    {
                                      setState(() {
                                        stopCamera = true;
                                      });
                                    }
                                    
                                  },
                                  color: !scattando ? Color.fromRGBO(255, 255, 255, .7) : Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    
                                  ),
                                  child: !scattando ? Container() : Text("STOP", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                  
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Future<void> _inizializzaCamera() async  {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription firstCamera = cameras.first;
    
    _controller = CameraController(firstCamera, ResolutionPreset.max, enableAudio: false);
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
        List<String> immaginiCatturate = new List<String>();

      for(int i = 0; i<this.numeroScatti; i++)
      {
        String temp = (await getTemporaryDirectory()).path;
        String path = join(temp, '${DateTime.now()}.png');

        setState(() {
          progress = i / numeroScatti;
        });

        immaginiCatturate.add(path);

        //print(path);
        
        await _controller.takePicture(path);

        
        

        // 200 millisecondi di delay
        //sleep(Duration(milliseconds: 200));

        if(stopCamera)
        {
          break;
        }
      }

      setState(() {
        progress = 0.0;
        scattando = false;
        stopCamera = false;
      });
      
      print("FINITO");
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