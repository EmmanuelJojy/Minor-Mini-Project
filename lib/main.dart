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
  var ip = "ws://192.168.14.206:81";
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
      channel = IOWebSocketChannel.connect(ip); //channel IP : Port
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
          log("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          log(error.toString());
        },
      );
    } catch (_) {
      log("error on connecting to websocket.");
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
        title: const Text("Privacy Gaurd"),
      ),
      body: Container(
          alignment: Alignment.topCenter, //inner widget alignment to center
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(20)),
              Container(
                //showing if websocket is connected or disconnected
                child: connected
                    ? const Text("NODE MCU WEBSOCKET CONNECTED")
                    : const Text("ALL WEBSOCKETS DISCONNECTED"),
              ),
              const Padding(padding: EdgeInsets.all(20)),
              Container(
                child: connected ? Text(ip) : const Text(""),
              ),
              const Padding(padding: EdgeInsets.all(20)),
              Container(
                child: connected
                    ? const Text("SURVEILLANCE MODE - ACTIVE")
                    : const Text("SURVEILLANCE MODE - DEACTIIVE"),
              ),
            ],
          )),
    );
  }
}
