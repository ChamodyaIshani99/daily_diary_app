import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Phone එකේ Biometrics (Fingerprint/FaceID) හෝ PIN Lock එක තියෙනවාදැයි පරීක්ෂා කිරීම
  static Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool isDeviceSupported = await _auth.isDeviceSupported();
    return canAuthenticateWithBiometrics || isDeviceSupported;
  }

  // Fingerprint / PIN මඟින් Auth කිරීම
  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return true; // Device එකේ Lock එකක් නැත්නම් කෙළින්ම App එකට යන්න ඉඩ දෙයි

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your Daily Diary',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Biometric නැත්නම් Phone PIN/Pattern එක පාවිච්චි කිරීමට ඉඩ දෙයි
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}