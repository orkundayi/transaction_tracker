enum IntegrationError {
  invalidRequest,
  unknown,
}

extension ErrorExtension on IntegrationError {
  String message() {
    switch (this) {
      case IntegrationError.invalidRequest:
        return 'Geçersiz istek.';
      case IntegrationError.unknown:
        return 'Bilinmeyen hata.';
    }
  }
}
