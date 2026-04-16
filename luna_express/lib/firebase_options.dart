import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAtF167ua5zEH-xhP2U9dObFWlQz3lF-Y',
    appId: '1:379163254734:web:01c36b90af156f2efa159f',
    messagingSenderId: '379163254734',
    projectId: 'lunaexpress',
    authDomain: 'lunaexpress.firebaseapp.com',
    storageBucket: 'lunaexpress.firebasestorage.app',
    measurementId: 'G-PJYTNGQR09',
  );
}