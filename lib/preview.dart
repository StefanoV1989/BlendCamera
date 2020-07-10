import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';

class PreviewFoto extends StatefulWidget {

  final List<String> immaginiCatturate;

  PreviewFoto({Key key, @required this.immaginiCatturate}) : super(key: key);

  @override
  _PreviewFotoState createState() => _PreviewFotoState();
}

class _PreviewFotoState extends State<PreviewFoto> {

  List<String> immaginiCatturate = new List<String>();
  
  ui.Image previewFinale;
  ByteData pngFinale;

  bool unioneCompletata = false;
  bool salvato = false;
  String testoLoading = "";

  @override
  void initState() {
    super.initState();
    immaginiCatturate = widget.immaginiCatturate;

    
    unisci();
  }

  @override
  Widget build(BuildContext context) {

    Image immagine;

    if(unioneCompletata) immagine = Image.memory(new Uint8List.view(pngFinale.buffer));

    return Scaffold(
      backgroundColor: Colors.black,
      body: unioneCompletata ? 
        Container(
          
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: PhotoView(
                  minScale: PhotoViewComputedScale.contained,
                  imageProvider: immagine.image,
                  /*width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,*/
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  color: Color.fromRGBO(0, 0, 0, .7),
                  child: Row(
                    mainAxisAlignment: (!salvato) ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromRGBO(255, 255, 255, .8), width: 2),
                          borderRadius: BorderRadius.circular(40)
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: RaisedButton(
                            padding: EdgeInsets.all(0),
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            child: Icon(Icons.arrow_back, color: Color.fromRGBO(255, 255, 255, .8),),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      (!salvato) ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromRGBO(255, 255, 255, .8), width: 2),
                          borderRadius: BorderRadius.circular(40)
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: RaisedButton(
                            padding: EdgeInsets.all(0),
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            child: Icon(Icons.save, color: Color.fromRGBO(255, 255, 255, .8),),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text("Do you want to save your blended image?", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                                    backgroundColor: Colors.black,
                                    actions: <Widget>[
                                      RaisedButton(
                                        
                                        onPressed: () {
                                          salvaImmagine().then((value){
                                            
                                            Navigator.of(context).pop();
                                            setState(() {
                                              salvato = true;
                                            });
                                          });
                                        },
                                        color: Colors.green,
                                        child: Text("OK", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                      RaisedButton(
                                        
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        color: Colors.red,
                                        child: Text("NO", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  );
                                }
                              );
                            },
                          ),
                        ),
                      ) : Container()
                    ],
                  ),
                ),
              )
            ],
          )
        )
       : Center(
         child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
              ),
              Container(padding: EdgeInsets.only(top: 15) ,child: Text(testoLoading, style: TextStyle(color: Colors.white, fontSize: 14),))
           ],
         ),),
    );
  }

  void unisci() async {
    
    setState(() {
      testoLoading = "Blending images...";
    });

    previewFinale = await blenda(await _convertImage(this.immaginiCatturate));

    if(!mounted) return ;

    setState(() {
      unioneCompletata = true;
    });
  }

  Future<void> salvaImmagine() async {
    print("salva");
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = join(appDocDirectory.path, '${DateTime.now()}.png');
    File(path).writeAsBytesSync(pngFinale.buffer.asInt8List());
    GallerySaver.saveImage(path).then((value)
    {
      // cancello il temp
      File(path).delete();
    });

  }

  Future<List<ui.Image>> _convertImage(List<String> images) async
  {
    List<ui.Image> temp = new List<ui.Image>();

    for(int i=0; i<images.length; i++)
    {
      temp.add( await _loadCapturedImage(images[i]));

      // elimino la foto scattata dalla cache
      File(images[i]).delete();
    }

    return temp;
  }

  Future<ui.Image> _loadCapturedImage(String path) async {
    Uint8List data = await File(path).readAsBytes();
    
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    
    ui.FrameInfo frame = await codec.getNextFrame();

   
    return frame.image;
  }

  @override
  void dispose() {

    if(previewFinale != null) previewFinale.dispose();
    super.dispose();
  }

  Future<ui.Image> blenda(List<ui.Image> immagini)  async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    ui.Canvas tela = new ui.Canvas(recorder);

    Paint paintImage = Paint()
    ..blendMode = BlendMode.lighten;

    

    double imageWidth = immagini[0].width.toDouble();
    double imageHeight = immagini[0].height.toDouble();

    for(int i=0;i<immagini.length; i++)
    {
      
      //print(imageWidth.toString() + "x" + imageHeight.toString());
      tela.drawImageRect(
        immagini[i], 
        Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
        Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
        (i == 0) ? Paint() : paintImage
      );

      
    }
    
    

    setState(() {
      testoLoading = "Generating Preview...";
    });

    //print("uno");
    ui.Picture picture = recorder.endRecording();
    //print("due");
    ui.Image img = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());
    //print("tre");
    pngFinale = await img.toByteData(format: ui.ImageByteFormat.png);
    //print("quattro");
    return img;
  }
}

/*class ImageFinalShower extends CustomPainter{
  ImageFinalShower({@required this.immagine});
  final ui.Image immagine;

  

  @override
  void paint(Canvas canvas, Size size) {
    
    
    double imageWidth = immagine.width.toDouble();
    double imageHeight = immagine.width.toDouble();

    canvas.drawImageRect(
      immagine, 
      Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
      Rect.fromLTWH(0.0,0.0,size.width,size.width), 
      Paint()
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}*/