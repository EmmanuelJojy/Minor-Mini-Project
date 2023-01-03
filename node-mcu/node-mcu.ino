#include <stdio.h>
#include <Arduino.h>
#include <ESP8266WiFi.h> //import for wifi functionality
#include <WebSocketsServer.h> //import for websocket

const char *ssid =  "AndroidAP7AC7";   //Wifi SSID (Name)   
const char *pass =  "abcdefghijkl"; //wifi password

int led = 5; 
int irs = 14;

WebSocketsServer webSocket = WebSocketsServer(81); //websocket init with port 81

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  String cmd = "";
  switch(type) {
    case WStype_DISCONNECTED: break;
    case WStype_CONNECTED:
      Serial.println("Websocket is connected"); 
      Serial.println(webSocket.remoteIP(num).toString());
      webSocket.sendTXT(num, "connected");
      break;
    case WStype_TEXT:
    case WStype_FRAGMENT_TEXT_START: 
    case WStype_FRAGMENT_BIN_START: break;
    case WStype_BIN: hexdump(payload, length); break;
  }
}


void setup() {
  pinMode(led, OUTPUT); pinMode(irs, INPUT); 
  delay(1000);
    
  Serial.begin(115200); 
  Serial.print("Connecting to: ");
  Serial.println(ssid);
  
  WiFi.mode(WIFI_STA); WiFi.begin(ssid, pass);
  while(WiFi.status() != WL_CONNECTED) { Serial.print("*"); delay(500); }
  
  Serial.print("\nConnected to Wi-Fi: "); Serial.println(WiFi.SSID());
  Serial.print("The URL of ESP8266 Web Server is: http://"); Serial.println(WiFi.localIP());  
  delay(1000);
  
  webSocket.begin(); //websocket Begin
  webSocket.onEvent(webSocketEvent); //set Event for websocket
  Serial.println("Websocket is started");
}

void loop() {
  webSocket.loop(); //keep this line on loop method
  
  int val = digitalRead(irs); 
  // int ana = analogRead(A0); Serial.print("Read - "); Serial.println(ana);
  
  if (val == HIGH) // low positive
  { 
    digitalWrite(led, LOW);   
  } 
  else 
  { 
    digitalWrite(led, HIGH);
    webSocket.broadcastTXT("LOCK");
    delay(5000);
  }
}