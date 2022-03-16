import 'package:flutter/material.dart';

import 'package:tdmfirebase/screens/place_screen.dart';
import 'package:tdmfirebase/screens/map.dart';

class NavigationOptions extends StatefulWidget {
  @override
  State<NavigationOptions> createState() => _NavigationOptionsState();
}

class _NavigationOptionsState extends State<NavigationOptions> {
  int _page = 0; // initial page
  PageController? pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: _page);
  }

  setPage(page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [
          PlaceScreen(),
          MapPage()
        ],
        onPageChanged: setPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Places'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Map'),
        ],
        onTap: (page) {
          pc?.animateToPage(page, duration: const Duration(milliseconds: 400), curve: Curves.ease);
        },
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}