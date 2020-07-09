import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

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

  @override
  void initState() {
    super.initState();
    immaginiCatturate = widget.immaginiCatturate;

    
    unisci();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Blend Camera"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              salvaImmagine().then((value)
              {
                print("Immagine salvata");
                Navigator.of(context).pop();
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          
          child: unioneCompletata ? SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Image.memory(new Uint8List.view(pngFinale.buffer),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          )
           : Center(child: CircularProgressIndicator(),),
        ),
      ),
    );
  }

  void unisci() async {
    
    previewFinale = await blenda(await _convertImage(this.immaginiCatturate));

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
    previewFinale.dispose();
    super.dispose();
  }

  Future<ui.Image> blenda(List<ui.Image> immagini)  async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    ui.Canvas tela = new ui.Canvas(recorder);

    Paint paintImage = Paint()
    ..blendMode = BlendMode.lighten;

    double imageWidth;
    double imageHeight;

    for(int i=0;i<immagini.length; i++)
    {
      imageWidth = immagini[i].width.toDouble();
      imageHeight = immagini[i].height.toDouble();
      print(imageWidth.toString() + "x" + imageHeight.toString());
      tela.drawImageRect(
        immagini[i], 
        Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
        Rect.fromLTWH(0.0,0.0,imageWidth,imageHeight), 
        (i == 0) ? Paint() : paintImage
      );
    }
    
    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(imageWidth.toInt(), imageHeight.toInt());
    pngFinale = await img.toByteData(format: ui.ImageByteFormat.png);
    
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