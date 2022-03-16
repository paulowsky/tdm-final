import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:tdmfirebase/screens/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyD3U_i5lwnr7E9sd6S05ZAxHCOule0KT4Y",
        appId: "1:411120685099:web:071a01018f8f66565a5a6e",
        authDomain: "tdm2022-1aa1b.firebaseapp.com",
        messagingSenderId: "411120685099",
        projectId: "tdm2022-1aa1b",
        storageBucket: "tdm2022-1aa1b.appspot.com"
      )
    );
  } else {
    await Firebase.initializeApp();
  }

  final CollectionReference _contatos = FirebaseFirestore.instance.collection('contatos');

  QuerySnapshot snapshot = await _contatos.get();
  snapshot.docs.forEach((element) {
    print(element.data().toString());
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      home: NavigationOptions()
    );
  }
}
