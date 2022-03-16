import 'package:flutter/material.dart';

abstract class GoogleMapAppPage extends StatelessWidget {
  const GoogleMapAppPage(this.leading, this.title);

  final Widget leading;
  final String title;
}