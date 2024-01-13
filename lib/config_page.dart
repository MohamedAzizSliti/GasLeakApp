import 'package:flutter/material.dart';
import 'package:gazfront/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  String brokerAdresse = "";
  String port = "";
  String topic = "";
  double seuil = 0.0;
  void _submit() async {
    try {
      print(seuil);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('SharedPreferences instance obtained successfully');
      await prefs.setString('brokerAdresse', brokerAdresse);
      await prefs.setString('port', port);
      await prefs.setString('topic', topic);
      await prefs.setDouble('seuil', seuil);

      // Now, after saving preferences, navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration'),
        leading: Icon(Icons.settings),
        actions: [
          // Adding an IconButton to set default values
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: () {
              setState(() {
                // Set default values
                brokerAdresse = 'broker.hivemq.com';
                port = '1883';
                topic = 'topic/gas';
                seuil = 1000.0;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  brokerAdresse = value;
                });
              },
              controller: TextEditingController(text: brokerAdresse),
              decoration: InputDecoration(
                labelText: 'Adresse du Broker',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  port = value;
                });
              },
              controller: TextEditingController(text: port),
              decoration: InputDecoration(
                labelText: 'Port',
                prefixIcon: Icon(Icons.router),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  topic = value;
                });
              },
              controller: TextEditingController(text: topic),
              decoration: InputDecoration(
                labelText: 'Topic',
                prefixIcon: Icon(Icons.message),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  seuil = double.parse(value);
                });
              },
              controller: TextEditingController(text: seuil.toString()),
              decoration: InputDecoration(
                labelText: 'Seuil',
                prefixIcon: Icon(Icons.graphic_eq),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submit();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Enregistrer et Continuer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
