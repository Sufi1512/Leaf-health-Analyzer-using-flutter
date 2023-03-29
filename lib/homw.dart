import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Potato Disease Classifier',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  bool _isLoading = false;
  List<dynamic>? _output;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    Tflite.close();
    String model = 'assets/model_unquant.tflite';
    String labels = 'assets/labels.txt';
    try {
      await Tflite.loadModel(
        model: model,
        labels: labels,
      );
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _isLoading = true;
        classifyImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _isLoading = true;
        classifyImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> classifyImage() async {
    try {
      var results = await Tflite.runModelOnImage(
        path: _image!.path,
        numResults: 2,
        threshold: 0.6,
        imageStd: 255,
        imageMean: 0.00,
      );
      List<dynamic> output = results == null ? [] : results;
      setState(() {
        _isLoading = false;
        _output = output;
      });
    } on PlatformException {
      print('Failed to run model.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Potato Disease Classifier'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _image == null
                ? Text('Take a picture to classify.')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.file(
                        _image!,
                        height: 200.0,
                        width: 200.0,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Classification: ${_output![0]['label']}',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Confidence: ${(_output![0]['confidence'] * 100).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: getImage,
            tooltip: 'Take Picture',
            child: Icon(Icons.camera),
          ),
          SizedBox(width: 16.0),
          FloatingActionButton(
            onPressed: getImageFromGallery,
            tooltip: 'Choose from Gallery',
            child: Icon(Icons.image),
          ),
        ],
      ),
    );
  }
}
