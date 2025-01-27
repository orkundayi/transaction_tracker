import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Intent;

import 'package:android_intent_plus/android_intent.dart';
import 'package:mutual/mutual.dart';
import 'package:receive_intent/receive_intent.dart';

import '../integration.dart';
import '../integration_base.dart';
import '../integration_method.dart';
import '../models/integration_error.dart';
import '../models/integration_response.dart';
import 'intent_handler.dart';

class IntentIntegrator {
  IntentIntegrator._();
  static IntentIntegrator? _instance;
  factory IntentIntegrator() => _instance ??= IntentIntegrator._();
  bool isActivated = false;

  Future<void> _sendResponse(String action) async {
    var response = <String, dynamic>{
      'HasError': Integration.response.hasError,
      'ErrorCode': Integration.response.errorCode,
      'Message': Integration.response.errorMessage,
      'Data': jsonEncode(Integration.response.data),
    }..removeWhere((key, value) => value == null);
    logLongString('IntentIntegrator._sendResponse - response: ${jsonEncode(response)}');
    var intent = AndroidIntent(
      action: action,
      type: 'application/json',
      package: Integration.packageName,
      arguments: response,
      flags: [0x10000000], //FLAG_ACTIVITY_NEW_TASK
    );

    await intent.launch();
  }

  Future<void> activate() async {
    if (isActivated) {
      return;
    }
    isActivated = true;
    IntentHandler(Integration.context).intentStream.listen((intent) async {
      if (Integration.intentIntegrator != null) {
        await process(intent);
      }
    }, onError: (error) {
      log.severe('Intent stream error: $error');
    });
  }

  void processInitial(BuildContext context) async {
    if (!isActivated) {
      await activate();
    }
    if (!Integration.context.mounted) {
      return;
    }
    var initialIntent = IntentHandler(Integration.context).initialIntent;
    if (Integration.isInitialIntent) {
      if (initialIntent != null &&
          IntegrationMethod.values
                  .toList()
                  .firstWhereOrNull((element) => element.intentInputAction() == initialIntent.action) !=
              null) {
        await process(initialIntent);
      }
    }
  }

  Future<void> process(Intent intent) async {
    Integration.packageName = intent.extra?['packageName'];
    var integrationMethod =
        IntegrationMethod.values.toList().firstWhereOrNull((element) => element.intentInputAction() == intent.action);
    if (integrationMethod == null) {
      return;
    } else if (integrationMethod.inputKey() != null && intent.extra?[integrationMethod.inputKey()] == 'null') {
      Integration.response =
          IntegrationResponse.error(IntegrationError.invalidRequest.index, IntegrationError.invalidRequest.message());
      await _sendResponse('${intent.action!}.result');
      return;
    } else {
      var data = integrationMethod.inputKey() != null && intent.extra != null
          ? intent.extra![integrationMethod.inputKey()]
          : null;
      Integration.startCompleter();
      IntegrationBase.service(integrationMethod).callMethod(jsonData: data).ignore();
      await Integration.completer!.future;
      await _sendResponse(integrationMethod.intentOutputAction()!);
    }
  }

  void logLongString(String message) {
    const int chunkSize = 1000; // Her parçanın boyutu
    for (int i = 0; i < message.length; i += chunkSize) {
      log.info(message.substring(i, i + chunkSize > message.length ? message.length : i + chunkSize));
    }
  }

  void dispose() {}
}
