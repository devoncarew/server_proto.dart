
import 'dart:convert' show JSON;
import 'dart:io';

void main(List args) {
  final int port = 3333;

  WebSocket.connect('ws://localhost:3333/').then(handleConnect);
}

WebSocket socket;

void handleConnect(WebSocket websocket) {
  socket = websocket;

  websocket.listen((data) {
    if (data is String) {
      _handleResponse(data);
    } else {
      print('received binary data for command; only string messages are supported');
    }
  });

  sendCommand('hello');
  sendCommand('there');
}

int _commandId = 0;

void sendCommand(String command, [Map params]) {
  Map m = {'command': command, 'id': ++_commandId};

  if (params != null) {
    m['params'] = params;
  }

  String str = JSON.encoder.convert(m);
  socket.add(str);
}

void _handleResponse(String data) {
  print(data);

  // TODO:

  Map m = JSON.decoder.convert(data);

}
