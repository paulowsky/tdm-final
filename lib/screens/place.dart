import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class Place extends StatelessWidget {
  Place(this.data, this.mine, this.scaffoldKey);

  final DocumentSnapshot<Object?> data;
  final bool mine;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          // 1 column
          !mine ? 
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: Image.network(data.get('senderPhotoUrl')).image,
              ),
            ) : Container(),
          // 2 column
          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Text('Latitude: '+data.get('lat').toString(), style: TextStyle(fontSize: 16)),
                Text('Longitude: '+data.get('lng').toString(), style: TextStyle(fontSize: 16)),
                
                Text(
                  data.get('placeName'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    var _lat = data.get('lat');
                    var _lng = data.get('lng');
                    _launchURL("https://www.google.com/maps/place/$_lat+$_lng/@$_lat,$_lng,15z");
                  },
                  icon: Icon(Icons.open_in_browser, size: 18),
                  label: Text("Open Place"),
                ),

                mine ? FlatButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text('Delete Place'),
                  onPressed: () {
                    _deletePlace(data.id, data.get('placeName'));
                  },
                ) : Container(),
                
                Text(
                  data.get('senderName'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700
                  ),
                )
              ],
            )
          ),
          // 3 column
          mine ? 
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundImage: Image.network(data.get('senderPhotoUrl')).image,
              ),
            ) : Container(),
        ],
      ),
    );
  }

  _deletePlace(String id, String name) async {
    final CollectionReference _places = FirebaseFirestore.instance.collection('places');
    _places.doc(id).delete();

    scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text('Place $name deleted!'))
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}