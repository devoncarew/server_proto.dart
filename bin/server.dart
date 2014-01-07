
import 'dart:convert' show JSON;
import 'dart:io';

import 'package:logging/logging.dart';

final Logger _logger = new Logger('spark.workspace');

void main(List args) {
  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 3333).then(_handleServer);
  print('listening on 3333...');
}

void _handleServer(HttpServer server) {
  server.listen((HttpRequest request) {
    if (request.headers[HttpHeaders.UPGRADE].indexOf('websocket') >= 0) {
      WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
        _handleWebSocket(websocket);
      });
    } else if (request.method == 'GET') {
      _handleGetRequest(request);
    } else {
      _returnError(request);
    }
  });
}

void _handleGetRequest(HttpRequest request) {
  // TODO:

  HttpResponse response = request.response;

  response.statusCode = HttpStatus.OK;
  response.headers.add(HttpHeaders.CONTENT_TYPE, "text/plain");
  response.write('Woot! Hello ${request.uri.path}.');
  response.close();
}

void _returnError(HttpRequest request) {
  HttpResponse response = request.response;

  response.statusCode = HttpStatus.NOT_FOUND;
  response.headers.add(HttpHeaders.CONTENT_TYPE, "text/plain");
  response.write('Not found');
  response.close();
}

void _handleWebSocket(WebSocket websocket) {
  new AnalysisServer(websocket);
}

class AnalysisServer {
  final WebSocket websocket;

  AnalysisServer(this.websocket) {
    websocket.listen((data) {
      if (data is String) {
        _handleCommand(data);
      } else {
        // List<int> (binary data). do not like
        _logger.warning(
            'received binary data for command; only string messages are supported');
      }
    });
  }

  void dispatchCommand(int id, String method, Map params) {
    print("received ${method}[${id}]: ${params}");
  }

  void _handleCommand(String rawCommand) {
    Map m = JSON.decoder.convert(rawCommand);

    int id = m['id'] != null ? m['id'] : 0;
    String method = m['method'];
    Map params = m['params'] != null ? m['params'] : {};

    dispatchCommand(id, method, params);
  }
}
