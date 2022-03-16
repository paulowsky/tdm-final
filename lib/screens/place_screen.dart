import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:tdmfirebase/screens/place.dart';

class PlaceScreen extends StatefulWidget {
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference _places = FirebaseFirestore.instance.collection('places');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null
            ? 'Signed in as ${_currentUser?.displayName}'
            : 'Places'
        ),
        elevation: 0,
        actions: <Widget>[
          _currentUser != null
            ? IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();
                _scaffoldKey.currentState?.showSnackBar(
                  SnackBar(content: Text('Logout'))
                );
              },
            )
            : ElevatedButton.icon(
              onPressed: () {
                _getUser(context: (context));
              },
              icon: Icon(Icons.switch_account, size: 18),
              label: Text("Login"),
            )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: _places
              .orderBy('time')
              .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Place(
                        documents[index],
                        documents[index].get('uid') == _currentUser?.uid,
                        _scaffoldKey
                      );
                    }
                  );
              }
            },
          )),
          _isLoading ? LinearProgressIndicator() : Container()
        ]
      )
    );
  }

  Future<User?> _getUser({required BuildContext context}) async {
    User? user;

    if (_currentUser != null) return _currentUser;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch(err) {
        print(err);
      }
    } else {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken
        );

        try {
          final UserCredential userCredential = await auth.signInWithCredential(credential);
          user = userCredential.user;
        } on FirebaseAuthException catch(err) {
          print(err);
        } catch(err) {
          print(err);
        }
      }
    }

    return user;
  }
}
