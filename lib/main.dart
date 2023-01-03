import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/io.dart';

import 'package:process_run/shell.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketDHT(),
    );
  }
}

//apply this class on home: attribute at MaterialApp()
class WebSocketDHT extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebSocketDHT();
  }
}

class _WebSocketDHT extends State<WebSocketDHT> {
  var ip = 
  late IOWebSocketChannel channel;
  late bool connected; //boolean value to track if WebSocket is connected

  @override
  void initState() {
    connected = false; //initially connection status is "NO" so its FALSE

    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket wth NodeMCU
    });

    super.initState();
  }

  Future<void> lockProcedure() async {
    await Shell().run('xdg-screensaver lock');
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.254.206:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          log(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            } else {
              debugPrint('Initiaitng Lock Screen Procedure');
              lockProcedure();
            }
            //you can apply "if elese - else if for more message type from NodeMCU"
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd); //sending Command to NodeMCU
      //send command to NodeMCU
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Privacy Gaurd"), backgroundColor: Colors.redAccent),
      body: Container(
          alignment: Alignment.topCenter, //inner widget alignment to center
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  //showing if websocket is connected or disconnected
                  child: connected
                      ? Text("WEBSOCKET CONNECTED at ")
                      : Text("DISCONNECTED")),
            ],
          )),
    );
  }
}
