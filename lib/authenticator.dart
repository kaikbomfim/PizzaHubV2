import 'package:pizzahub_v2/usuario.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authenticator {
  static Future<User> login() async {
    final gUser = await GoogleSignIn().signIn();
    final user = User(gUser!.displayName, gUser.email);

    return user;
  }

  static Future<User?> recoverUser() async {
    User? user;

    final gSignIn = GoogleSignIn();
    if (await gSignIn.isSignedIn()) {
      await gSignIn.signInSilently();

      final gUser = gSignIn.currentUser;
      if (gUser != null) {
        user = User(gUser.displayName, gUser.email);
      }
    }

    return user;
  }

  static Future<void> logout() async {
    await GoogleSignIn().signOut();
  }
}
