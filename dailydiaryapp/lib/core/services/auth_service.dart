import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Check whether the device has biometrics (fingerprint/Face ID) or a PIN lock enabled
  static Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool isDeviceSupported = await _auth.isDeviceSupported();
    return canAuthenticateWithBiometrics || isDeviceSupported;
  }

  // Authenticate using fingerprint or PIN
  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return true; // If the device has no lock, allow access to the app directly

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your Daily Diary',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // If biometrics are unavailable, allow the phone PIN/pattern to be used
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}