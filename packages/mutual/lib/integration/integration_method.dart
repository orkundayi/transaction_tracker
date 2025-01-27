enum IntegrationMethod {
  loginWithAdmin,
}

extension IntegrationMethodExtension on IntegrationMethod {
  String uriPath() {
    switch (this) {
      case IntegrationMethod.loginWithAdmin:
        return 'loginWithAdmin';
    }
  }

  String serialOperation() {
    switch (this) {
      case IntegrationMethod.loginWithAdmin:
        return 'LoginWithAdmin';
    }
  }

  String? intentInputAction() {
    switch (this) {
      case IntegrationMethod.loginWithAdmin:
        return 'pavopay.intent.action.login.with.admin';
    }
  }

  String? intentOutputAction() {
    switch (this) {
      case IntegrationMethod.loginWithAdmin:
        return 'pavopay.intent.action.login.with.admin.result';
    }
  }

  String? inputKey() {
    switch (this) {
      case IntegrationMethod.loginWithAdmin:
        return 'Login';
    }
  }
}
