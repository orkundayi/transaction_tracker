import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mutual/mutual.dart';

import 'intent/intent_integrator.dart';
import 'models/integration_error.dart';
import 'models/integration_response.dart';
import 'rest/rest_integrator.dart';

class Integration {
  static late BuildContext context;
  static late IntegrationResponse response;
  static IntentIntegrator? intentIntegrator;
  static RestIntegrator? restIntegrator;
  static Completer? completer;
  static bool hasIntegration = false;
  static bool isInitialIntent = true;

  static String? packageName;

  static Future initialize(
    BuildContext context, {
    IntegrationType? integrationType,
  }) async {
    Integration.context = globalNavigator.currentState?.context ?? context;
    dispose();
    switch (integrationType) {
      case IntegrationType.intent:
        await _initializeIntent();
        break;
      case IntegrationType.rest:
        await _initializeRest();
        break;
      default:
        break;
    }

    if (context.mounted) {
      processInitialRequest(context);
    }
  }

  static Future _initializeIntent() async {
    intentIntegrator = IntentIntegrator();
  }

  static Future _initializeRest() async {
    restIntegrator = RestIntegrator();
  }

  static void processInitialRequest(BuildContext context) {
    restIntegrator!.processInitial(context);
    intentIntegrator!.processInitial(context);
  }

  static void dispose() {
    if (restIntegrator != null) {
      restIntegrator!.dispose();
      restIntegrator = null;
    }
  }

  static void setIntegrationError({
    required IntegrationError integrationError,
    List<dynamic>? customErrors,
    Map<String, dynamic>? data,
  }) async {
    List<dynamic> errors = [];
    if (customErrors == null || customErrors.isEmpty) {
      errors.add(integrationError.message());
    } else {
      errors = customErrors;
    }

    data ??= {
      'Errors': errors,
    };

    response = IntegrationResponse.error(
      integrationError.index,
      errors.first,
      data,
    );
  }

  static void startCompleter() {
    completer = Completer();
  }

  static Future completeCompleter() async {
    completer!.complete();
  }

  static void activate(BuildContext context) {
    intentIntegrator?.activate();
    restIntegrator?.activate();
  }
}

enum IntegrationType {
  intent,
  rest,
}
