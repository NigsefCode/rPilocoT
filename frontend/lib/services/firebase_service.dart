import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<String?> getFirebaseToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken();
  }
}
