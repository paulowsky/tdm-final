import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

import 'page.dart';

const CameraPosition _kInitialPosition =
    CameraPosition(target: LatLng(-28.2596788, -52.4057722), zoom: 14.0);

class MapPage extends StatefulWidget {
  const MapPage();

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? _currentUser;

  MapPageState();

  GoogleMapController? mapController;
  LatLng? _lastTap;
  final _textController = TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      onTap: (LatLng pos) {
        setState(() {
          _lastTap = pos;
        });
      },
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            width: MediaQuery.of(context).size.width,
            child: googleMap,
          ),
        ),
      ),
    ];

    if (mapController != null) {
      final String lastTap = 'Coordinates:\n${_lastTap ?? ""}\n';
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(lastTap)
        )
      );

      columnChildren.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * .1,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration:
                      InputDecoration.collapsed(hintText: "Name that place"),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.length > 0;
                      });
                    },
                    onSubmitted: (text) {
                      _reset();
                    },
                  )
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_add, color: Colors.blue,),
                  onPressed: (_lastTap != null && _isComposing) ? () {
                    _sendPlace();
                  }: null,
                )
              ],
            )
          )
        )
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });
  }

  void _reset() {
    setState(() {
      _textController.text = '';
      _lastTap = null;
    });
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

    _currentUser = user;

    return user;
  }

  void _sendPlace() async {
    final CollectionReference _places = FirebaseFirestore.instance.collection('places');

    User? user = await _getUser(context: context);

    if (user == null) {
      const snackBar = SnackBar(
        content: Text('Authentication failed!'),
        backgroundColor: Colors.red
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Map<String, dynamic> data = {
      'time': Timestamp.now(),
      'lat': 0.0,
      'lng': 0.0,
      'placeName': _textController.text,
      'uid': user?.uid,
      'senderName': user?.displayName,
      'senderPhotoUrl': user?.photoURL
    };

    String userId = '';
    if (user != null && _lastTap != null) {
      userId = user.uid;
      data['lat'] = _lastTap?.latitude;
      data['lng'] = _lastTap?.longitude;
      _reset();
    }

    _places.add(data);
    print('place sent: ' + data.toString());

    const snackBar = SnackBar(
      content: Text("Place added!"),
      backgroundColor: Colors.amber
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}