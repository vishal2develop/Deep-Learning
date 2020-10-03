import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class PlantSpeciesRecognition extends StatefulWidget {
  final int model_type;
  PlantSpeciesRecognition(this.model_type);
  //PlantSpeciesRecognition(int model_type);

  @override
  State<StatefulWidget> createState() => new _PlantSpeciesRecognitionState();
}

class _PlantSpeciesRecognitionState extends State<PlantSpeciesRecognition> {
  //File _image;
  File _image;
  //var _image;
  List _recognitions;
  bool _busy = false;
  String str;

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    Size size = MediaQuery.of(context).size;
    stackChildren.clear();
    // TODO: implement build

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Text('No Image Selected') : Image.file(_image),
    ));

    if (widget.model_type == 0) {
      // To display Predictions
      //Here, we have used the value of _recognitions to create a Text with a specified color and background.
      //We then added this Text as a child to a column and aligned the Text to display at the center of the screen.
      stackChildren.add(Center(
          child: Column(
        children: <Widget>[
          str != null
              ? new Text(str,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    background: Paint()..color = Colors.white,
                  ))
              : new Text('No Results')
        ],
      )));
    } else if (widget.model_type == 1) {
      // Adding the results of TensorFlow Lite
      stackChildren.add(Center(
          child: Column(
        children: _recognitions != null
            ? _recognitions.map((res) {
                return Text(
                  '${res['label']}:${res['confidence'].toStringAsFixed(4)}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    background: Paint()..color = Colors.white,
                  ),
                );
              }).toList()
            : [],
      )));
    }

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Species Recognition'),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: chooseImageGallery,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }

  Future chooseImageGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return;
    setState(() {
      _busy = true;
      _image = image;
    });
    //Deciding on which method should be chosen for image analysis
    if (widget.model_type == 0) {
      await visionAPICall();
    } else if (widget.model_type == 1) {
      await loadModel();
      await predictImage(image);
    }
    setState(() {
      _image = image;
      _busy = false;
    });
  }

// method to create a request URL and make an http POST request
  Future visionAPICall() async {
    List<int> imageBytes = _image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    //create the request string
    var request_str = {
      "requests": [
        {
          "image": {"content": "$base64Image"},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 1}
          ]
        }
      ]
    };
    var url =
        'https://vision.googleapis.com/v1/images:annotate?<API_KEY>';
    //Make an HTTP post request using the http.post() method, passing in the url and the response string
    var response = await http.post(url, body: json.encode(request_str));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    //Since the response from the server is in JSON format, we use json.decode() to decode it,
    // and, further, parse it to store the desired values in the str variable
    var responseJson = json.decode(response.body);
    str =
        '${responseJson["responses"][0]["labelAnnotations"][0]["description"]}: ${responseJson["responses"][0]["labelAnnotations"][0]["score"].toStringAsFixed(3)}';
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
          model: "assets/model.tflite", labels: "assets/labels.txt");

      print('Model Loaded: $res');
    } on PlatformException {
      print("Failed to load the model");
    }

    //run the model on the image
    // var recognitions = await Tflite.runModelOnImage(path: _image.path);
    // setState(() {
    //   _recognitions = recognitions;
    // });

    // print('Recognition Result: $_recognitions');
  }

  predictImage(File image) async {
    if (image == null) return;

    var recognitions = await Tflite.runModelOnImage(path: _image.path);
    setState(() {
      _recognitions = recognitions;
    });
    print('Recognition Result: $_recognitions');
  }
}
