import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:gazfront/notifi_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MqttServerClient client;
  double gasValue = 0.0;
  late String brokerAdresse;
  late String port;
  late String topic;
  late double seuil;
  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> connectToMqtt() async {
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.pongCallback = pong;

    final connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier('dart_client')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(mqtt.MqttQos.atLeastOnce);

    print('client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on mqtt.NoConnectionException catch (e) {
      print('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('socket exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == mqtt.MqttConnectionState.connected) {
      print('client connected');
      // Subscribe to the gas topic
      client.subscribe(topic, mqtt.MqttQos.exactlyOnce);

      // Setup a listener for incoming messages on the gas topic
      client.updates!
          .listen((List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> c) {
        final mqtt.MqttPublishMessage message =
            c[0].payload as mqtt.MqttPublishMessage;
        final String payload = mqtt.MqttPublishPayload.bytesToStringAsString(
            message.payload.message);

        // Assuming the payload is a double value, update the gasValue
        setState(() {
          gasValue = double.parse(payload);

          // Check if gas value exceeds the threshold (seuil)
          if (gasValue > seuil) {
            // Show alert
            _showGasAlert();
          }
        });
      });
    } else {
      print(
          'client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void disconnectMqtt() {
    client.disconnect();
  }

  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        mqtt.MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
    }
  }

  void onConnected() {
    print('OnConnected client callback - Client connection was successful');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void _showGasAlert() async {
    final player = AudioPlayer();
    player.play(AssetSource('alarm-1-with-reverberation-30031.mp3'));
    // Vibrate
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate();
    }
    NotificationService()
        .showNotification(title: 'Sample title', body: 'It works!');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Danger!',
            style: TextStyle(color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 36.0,
              ),
              SizedBox(height: 10),
              Text(
                'Gas value exceeds the danger threshold: ${seuil}',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                player.stop();
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
              'assets/gas.json',
              width: 250.0,
              height: 250.0,
              repeat: true,
              animate: true,
            ),
            SizedBox(height: 20.0),
            Text(
              'Gas Value: $gasValue',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 24.0,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      "Embrace the power of resilience. Life is filled with challenges, but your ability to "
                      "bounce back, learn, and adapt will determine your strength and success in the face of adversity.",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Navigate back to the home page
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings), // Add the desired icon
                  SizedBox(width: 8.0), // Add spacing between icon and text
                  Text('Change Configuration'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      brokerAdresse = prefs.getString('brokerAdresse') ?? '';
      port = prefs.getString('port') ?? '';
      topic = prefs.getString('topic') ?? '';
      seuil = prefs.getDouble('seuil') ?? 0.0;
    });
    // Now that the data is loaded, initialize and connect to MQTT
    client = MqttServerClient(brokerAdresse, port);
    NotificationService().initNotification();
    connectToMqtt();
  }
}
