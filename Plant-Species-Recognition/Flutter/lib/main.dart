import 'package:flutter/material.dart';
import 'package:plant_recognition/plant_species_recognition.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var str_cloud = 'Cloud Vision API';
  var str_tensor = 'TensorFlow Lite';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Plant Species Recognition'),
        ),
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildRowTitle(context, 'Choose Model'),
            createButton(str_cloud),
            createButton(str_tensor),
          ],
        )));
  }

  Widget buildRowTitle(BuildContext context, String title) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline,
        ),
      ),
    );
  }

  // method for creating buttons
  Widget createButton(String chosenModel) {
    return (RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      splashColor: Colors.blueGrey,
      child: new Text(chosenModel),
      onPressed: () {
        var model_type = (chosenModel == str_cloud ? 0 : 1);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantSpeciesRecognition(model_type),
          ),
        );
      },
    ));
  }
}
