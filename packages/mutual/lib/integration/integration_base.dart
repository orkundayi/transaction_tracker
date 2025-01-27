import 'package:flutter/foundation.dart' show immutable;
import 'package:get_it/get_it.dart';

import 'integration_method.dart';

@immutable
abstract class IntegrationBase {
  const IntegrationBase();
  Future callMethod({String? jsonData}) async {}
  factory IntegrationBase.service(IntegrationMethod method) {
    switch (method) {
      default:
        throw 'Unsupported method';
    }
  }
  static void register() {
    GetIt getIt = GetIt.instance;
    //getIt.registerLazySingleton(() => AbandonSuspendedSale());
  }
}
