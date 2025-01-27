import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mutual/mutual.dart';
import '../integration.dart';
import '../integration_method.dart';
import '../models/integration_error.dart';
import '../models/integration_response.dart';

class RestIntegrator {
  bool _isActivated = false;
  Map dataMap = {};
  HttpServer? _server;

  void processInitial(BuildContext context) {
    Integration.activate(context);
  }

  Future<void> activate() async {
    if (_isActivated) {
      return;
    }

    _server = await HttpServer.bind(InternetAddress.anyIPv6, 4568);

    _server!.listen(
      (request) async {
        _handleGetRequest(request).ignore();
      },
      onDone: () async {},
      onError: (Object error, [StackTrace? stackTrace]) async {
        log.severe('Rest server error occured', error, stackTrace);
      },
    );
  }

  Future<void> _handleGetRequest(HttpRequest request) async {
    var requestBytesBuilder = BytesBuilder();
    await for (var data in request) {
      requestBytesBuilder.add(data);
    }
    String stringData = utf8.decode(requestBytesBuilder.toBytes());
    dataMap = json.decode(stringData);
    var integrationMethod =
        IntegrationMethod.values.toList().firstWhereOrNull((element) => element.uriPath() == request.uri.path);
    if (integrationMethod != null &&
        integrationMethod.inputKey() != null &&
        dataMap[integrationMethod.inputKey()] == null) {
      Integration.response =
          IntegrationResponse.error(IntegrationError.unknown.index, IntegrationError.unknown.message());
      _sendResponse(request).ignore();
      return;
    }
  }

  Future<void> _sendResponse(HttpRequest request) async {
    var response = jsonEncode({
      'HasError': Integration.response.hasError,
      'ErrorCode': Integration.response.errorCode,
      'Message': Integration.response.errorMessage,
      'Data': Integration.response.data,
    });
    request.response
      ..headers.contentType = ContentType.json
      ..headers.set('Access-Control-Allow-Origin', '*')
      ..write(response)
      ..close().ignore();
  }

  void dispose() {
    _server?.close(force: true);
    _isActivated = false;
  }
}
