import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:tflite/tflite.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List? _predictions = [];
  bool _loading = true;
  late File _image;
  final imagepicker = ImagePicker();

  void initState() {
    super.initState();
    loadmodel();
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.3,
      imageMean: 0.0,
      imageStd: 255,
    );
    setState(() {
      _predictions = prediction;
      _loading = false;
    });
  }

  _loadimage_gallary() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      setState(() {
        _loading = false;
      });
      _image = File(image.path);
    }
    detect_image(_image);
  }

  _loadimage_camera() async {
    final image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      setState(() {
        _loading = false;
      });
      _image = File(image.path);
    }
    detect_image(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: NewGradientAppBar(
          title: Text('Leaf Health Analyzer',
              style: GoogleFonts.aBeeZee(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: true,
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 2, 175, 94),
            Colors.purple,
            Color.fromARGB(255, 38, 147, 236)
          ])),
      body: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Color.fromARGB(255, 12, 155, 105),
          ],
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 180,
              padding: EdgeInsets.all(10),
              // color: Color.fromARGB(221, 215, 61, 61),
              child: Image.asset('assets/leaf1.png'),
            ),
            Container(
                child: Text(
              'Leaf Health Analyzer',
              style: GoogleFonts.aBeeZee(
                  fontSize: 20, fontWeight: FontWeight.bold),
            )),
            Container(
              width: double.infinity,
              height: 70,
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  _loadimage_camera();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Color.fromARGB(255, 11, 7, 7))))),
                child: Text(
                  'Capture',
                  style: GoogleFonts.aBeeZee(),
                ),
              ),
            ),
            Container(
                width: double.infinity,
                height: 70,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    _loadimage_gallary();
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: Color.fromARGB(255, 11, 7, 7))))),
                  child: Text(
                    'Gallery',
                    style: GoogleFonts.aBeeZee(),
                  ),
                )),
            _loading == false
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Image.file(_image),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Classification: ${_predictions![0]['label']}',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Confidence: ${(_predictions![0]['confidence'] * 100).toStringAsFixed(2)}%',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
