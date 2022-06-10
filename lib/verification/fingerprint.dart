import 'package:local_auth/local_auth.dart';

class FingerPrint{
  static Future<bool> authenticateWithFingerPrint() async {
    final LocalAuthentication localAuthentication = LocalAuthentication();
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    bool isAuthenticated = false;

    if (isBiometricSupported && canCheckBiometrics) {
      isAuthenticated = await localAuthentication.authenticate(
          localizedReason: 'Please complete the biometrics to proceed.',
          options: AuthenticationOptions(biometricOnly: true)
      );
    }

    return isAuthenticated;
  }

}