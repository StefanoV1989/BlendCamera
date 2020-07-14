import 'dart:io';
//import 'dart:ui' as ui;

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:screen/screen.dart';
import 'dart:ui' as ui;



Future<List<img.Image>> _convertImage(List<String> images) async
{
  
  List<img.Image> temp = new List<img.Image>();

  for(int i=0; i<images.length; i++)
  {
    //temp.add( await _loadCapturedImage(images[i]));
    temp.add( img.decodeImage(File(images[i]).readAsBytesSync()));

    // elimino la foto scattata dalla cache
    //File(images[i]).delete();
  }
  
  return temp;
}

  /*Future<img.Image> _loadCapturedImage(String path) async {
    Uint8List data = File(path).readAsBytesSync();
    
    img.Image imgPresa = img.decodeJpg(data.buffer.asUint8List());

   
    return imgPresa;
  }*/

int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

img.Image mediano(List<img.Image> immagini) {

    
    img.Image result;

    int imgWidth = immagini[0].width;
    int imgHeight = immagini[0].height;

    
    
    result = new img.Image(imgWidth, imgHeight);
    
    
    for(int x=0; x<imgWidth; x++)
    {
      for(int y=0; y<imgHeight; y++)
      {
        List<int> rossi = new List<int>();
        List<int> verdi = new List<int>();
        List<int> blu = new List<int>();

        for(int i=0;i<immagini.length;i++)  
        {

          
          Color colore = Color(abgrToArgb(immagini[i].getPixel(x, y)));

          rossi.add(colore.red);
          verdi.add(colore.green);
          blu.add(colore.blue);

        }

        result.setPixel(x, y, img.getColor(rossi.reduce((a, b) => a + b) ~/ rossi.length, verdi.reduce((a, b) => a + b) ~/ verdi.length, blu.reduce((a, b) => a + b) ~/ blu.length));
      }
    }

      
    

    /*if(free)
    {
      // watermark

    }*/
    
    /*int pixel1 = immagine1.getPixel(0, 0);
    int hex = abgrToArgb(pixel1);


    
    print(pixel1);
    print(hex);
    print(Color(hex));
    print(Color(hex).red);
    print(Color(hex).green);
    print(Color(hex).blue);
    print(Color(hex).value);
    print(img.getColor(Color(hex).red, Color(hex).green, Color(hex).blue));*/

    

    return result;

    
  }

class PreviewFoto extends StatefulWidget {

  final List<String> immaginiCatturate;
  final NativeDeviceOrientation orientamento;
  final bool fast;

  PreviewFoto({Key key, @required this.immaginiCatturate, @required this.orientamento, @required this.fast}) : super(key: key);

  @override
  _PreviewFotoState createState() => _PreviewFotoState();
}

class _PreviewFotoState extends State<PreviewFoto> {

  List<String> immaginiCatturate = new List<String>();
  
  //img.Image previewFinale;
  img.Image jpgFinale;

  bool free = false;

  bool unioneCompletata = false;
  bool salvato = false;
  bool waitSalvato = false;
  String testoLoading = "";
  img.Image watermark;
  bool fast;


  NativeDeviceOrientation orient;

  @override
  void initState() {
    Screen.keepOn(true);
    super.initState();
    
    fast = widget.fast;
    immaginiCatturate = widget.immaginiCatturate;
    orient = widget.orientamento;
    
    unisci();
    
    
  }

  

  @override
  Widget build(BuildContext context) {

    //Image immagine;
    

    if(unioneCompletata)
    {
      
      if(orient == NativeDeviceOrientation.portraitDown || orient == NativeDeviceOrientation.portraitUp)
      {
        
        
        if(jpgFinale.width > jpgFinale.height)
        {
          
          jpgFinale = img.copyRotate(jpgFinale, 90);
        } 
      }
    }

    //if(unioneCompletata) immagine = Image.memory(new Uint8List.view(pngFinale.buffer));
    
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
                  imageProvider: MemoryImage(img.encodeJpg(jpgFinale)),
                  /*width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,*/
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  color: Color.fromRGBO(0, 0, 0, .6),
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
                            onPressed: () async {
                              setState(() {
                                testoLoading = "Saving Image...";
                                unioneCompletata = false;
                                
                              });
                              await salvaImmagine();
                              setState(() {
                                salvato = true;
                                unioneCompletata = true;
                              });
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
      testoLoading = "Opening " + immaginiCatturate.length.toString() + " images " + (fast ? "(fast)" : "(slow)") + "...";
    });
    
    if(this.fast)
    {
      
      List<ui.Image> lista = await _convertUiImage(immaginiCatturate);
      
      setState(() {
        testoLoading = "Blending " + immaginiCatturate.length.toString() + " images (fast)...";
      });

      jpgFinale = await blenda(lista);
      
    }
    else
    {
      List<img.Image> lista = await compute(_convertImage, immaginiCatturate);

      setState(() {
        testoLoading = "Blending " + immaginiCatturate.length.toString() + " images (slow)...";
      });

      jpgFinale = await compute(mediano, lista);
    }

    if(!mounted) return ;
    
    setState(() {
      unioneCompletata = true;
    });
  }

  

  

  

  Future<void> salvaImmagine() async {
    //print("salva");
    
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = join(appDocDirectory.path, '${DateTime.now()}.png');
    File(path).writeAsBytesSync(img.encodeJpg(jpgFinale));
    
    GallerySaver.saveImage(path).then((value)
    {
      // cancello il temp
      File(path).delete();
    });

  }

  

  @override
  void dispose() {
    Screen.keepOn(false);
    if(jpgFinale != null) jpgFinale = null;
    super.dispose();
  }

  

  Future<img.Image> blenda(List<ui.Image> immagini)  async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    ui.Canvas tela = new ui.Canvas(recorder);

    Paint paintImage = Paint()
    ..blendMode = BlendMode.lighten;

    print(immagini);
    ByteData result;
    img.Image finale;

    double imageWidth = immagini[0].width.toDouble();
    double imageHeight = immagini[0].height.toDouble();

    for(int i=0;i<immagini.length; i++)
    {
      tela.drawImageRect(
        immagini[i], 
        Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
        Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
        (i == 0) ? Paint() : paintImage
      );
    }
    

    //print("uno");
    ui.Picture picture = recorder.endRecording();

    
    //print("due");
    ui.Image toImage = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());
    //print("tre");
    result = await toImage.toByteData(format: ui.ImageByteFormat.png);

    finale = img.decodePng(result.buffer.asUint8List());
    //print("quattro");
    return finale;
  }

Future<List<ui.Image>> _convertUiImage(List<String> images) async
{
  
  List<ui.Image> temp = new List<ui.Image>();

  for(int i=0; i<images.length; i++)
  {
    //temp.add( await _loadCapturedImage(images[i]));
    Uint8List bytes = await File(images[i]).readAsBytes();
    ui.Codec codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    ui.FrameInfo frame = await codec.getNextFrame();
    temp.add(frame.image);

    // elimino la foto scattata dalla cache
    File(images[i]).delete();
  }
  
  return temp;
}

  


  
} // chiusura classe



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