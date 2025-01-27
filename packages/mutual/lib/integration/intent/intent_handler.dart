import 'dart:async';

import 'package:flutter/widgets.dart' hide Intent;
import 'package:mutual/mutual.dart';
import 'package:receive_intent/receive_intent.dart';

class IntentHandler {
  IntentHandler._();
  static final IntentHandler _instance = IntentHandler._();
  factory IntentHandler(BuildContext context) {
    _instance._context = context;
    return _instance;
  }

  late BuildContext _context;
  Intent? initialIntent;

  StreamController<Intent>? _intentStreamController;
  Stream<Intent> get intentStream {
    _intentStreamController ??= StreamController<Intent>();
    return _intentStreamController!.stream;
  }

  StreamSubscription? _intentSubscription;

  void dispose() {
    _intentSubscription?.cancel();
  }

  Future<void> initialize(BuildContext context) async {
    _context = context;

    initialIntent = await ReceiveIntent.getInitialIntent();
    if (initialIntent != null) {
      if (canProcess(initialIntent!)) {
        await process(initialIntent!);
      }
    }

    _intentSubscription = ReceiveIntent.receivedIntentStream.listen((intent) {
      if (intent != null) {
        if (canProcess(intent)) {
          process(intent);
        } else {
          _intentStreamController?.add(intent);
        }
      }
    });
  }

  bool canProcess(Intent intent) {
    switch (intent.action) {
      case 'android.intent.action.MAIN':
        return true;
      default:
        return false;
    }
  }

  Future<void> process(Intent intent) async {
    log.fine('Intent received. ${intent.action}');
  }
}
