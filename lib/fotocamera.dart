

//import 'package:camera/camera.dart';
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

  List<CameraDescription> cameras;
  int indiceCamera = 0;

  @override
  void initState() {
    super.initState();

    //SystemChrome.setEnabledSystemUIOverlays([]);
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); // toglie fullscreen
    
    camere().then((value) {
      _inizializzaCamera(cameras.first);
    });
    
  }

  Future<void> camere() async {
    cameras = await availableCameras();
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
                            child: (!scattando) ? DropdownButton(
                              iconEnabledColor: Colors.transparent,
                              iconDisabledColor: Colors.transparent,
                              isExpanded: true,
                              underline: Container(),
                              dropdownColor: Color.fromRGBO(0, 0, 0, .3),
                              value: numeroScatti,
                              items: (!scattando) ? [
                                
                                DropdownMenuItem(value: 3, child: Center(child: Text("3 frames", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)),),
                                DropdownMenuItem(value: 5, child: Center(child: Text("5 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 7, child: Center(child: Text("7 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 10, child: Center(child: Text("10 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 15, child: Center(child: Text("15 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 20, child: Center(child: Text("20 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 25, child: Center(child: Text("25 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 30, child: Center(child: Text("30 frames", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                DropdownMenuItem(value: 0, child: Center(child: Text("Unlimited", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),),
                                
                              ] : null,
                              onChanged: (value) {
                                
                                setState(() {
                                  numeroScatti = value;
                                });
                              },
                            ) : Container(child: Text("...")),
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
                                  child: !scattando ? Container() : Text("STOP", style: TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                                  
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: (!scattando) ? IconButton(
                            color: Colors.transparent,
                            icon: Icon(Icons.switch_camera, color: Color.fromRGBO(255, 255, 255, .7), size: 40,),
                            onPressed: () {
                              print("cambia fotocamera");

                              int numCamere = cameras.length - 1;

                              if(indiceCamera < numCamere)
                              {
                                setState(() {
                                  indiceCamera++;
                                });
                              }
                              else
                              {
                                indiceCamera = 0;
                              }

                              _inizializzaCamera(cameras[indiceCamera]);

                              //_inizializzaCamera(cameras[1]);
                              
                            },
                          ) : Container( child: Text("..."),),
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

  Future<void> _inizializzaCamera(CameraDescription qualeCamera) async  {
    
    
    _controller = CameraController(qualeCamera, ResolutionPreset.max, enableAudio: false);

    
    _initializeControllerFuture = _controller.initialize();

    //

    //_controller.applyExposureCompensation(exposureValue: 3);

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

      int scattiDaFare;

      if(this.numeroScatti > 0)
      {
        scattiDaFare = this.numeroScatti;
      }
      else
      {
        scattiDaFare = 9999;
      }

      for(int i = 0; i<scattiDaFare; i++)
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