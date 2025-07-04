
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDnSKPUtrGypYvD54kIYec_J9CqBNPstnM',
    appId: '1:896422738232:web:95cffe01c6db2e313aa9cd',
    messagingSenderId: '896422738232',
    projectId: 'neuroapp-5d6c2',
    authDomain: 'neuroapp-5d6c2.firebaseapp.com',
    storageBucket: 'neuroapp-5d6c2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpCQ3BkXksF_gumfJohb26QKkkMojfnZc',
    appId: '1:896422738232:android:8616fa1624ec55bc3aa9cd',
    messagingSenderId: '896422738232',
    projectId: 'neuroapp-5d6c2',
    storageBucket: 'neuroapp-5d6c2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB6JeVXvAa2k5VyguDH0XWPFonwXC-LpRQ',
    appId: '1:896422738232:ios:d31692b87091ae5f3aa9cd',
    messagingSenderId: '896422738232',
    projectId: 'neuroapp-5d6c2',
    storageBucket: 'neuroapp-5d6c2.firebasestorage.app',
    iosBundleId: 'com.example.neuroApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB6JeVXvAa2k5VyguDH0XWPFonwXC-LpRQ',
    appId: '1:896422738232:ios:d31692b87091ae5f3aa9cd',
    messagingSenderId: '896422738232',
    projectId: 'neuroapp-5d6c2',
    storageBucket: 'neuroapp-5d6c2.firebasestorage.app',
    iosBundleId: 'com.example.neuroApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDnSKPUtrGypYvD54kIYec_J9CqBNPstnM',
    appId: '1:896422738232:web:cbc0cd0bf848d2b73aa9cd',
    messagingSenderId: '896422738232',
    projectId: 'neuroapp-5d6c2',
    authDomain: 'neuroapp-5d6c2.firebaseapp.com',
    storageBucket: 'neuroapp-5d6c2.firebasestorage.app',
  );
}
