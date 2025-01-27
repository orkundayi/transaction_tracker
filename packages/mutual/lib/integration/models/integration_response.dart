import 'dart:convert';

class IntegrationResponse {
  bool hasError = false;
  String? errorMessage;
  int? errorCode;
  Map<String, dynamic>? data;

  IntegrationResponse();

  factory IntegrationResponse.success(Map<String, dynamic>? data) {
    return IntegrationResponse()..data = data;
  }

  factory IntegrationResponse.error(int errorCode, String errorMessage, [Map<String, dynamic>? data]) {
    return IntegrationResponse()
      ..hasError = true
      ..errorMessage = errorMessage
      ..errorCode = errorCode
      ..data = data;
  }

  Map<String, dynamic> toMap() {
    return {
      'HasError': hasError,
      'ErrorMessage': errorMessage ?? '',
      'ErrorCode': errorCode,
      'Data': data == null ? '' : jsonEncode(data),
    };
  }
}
