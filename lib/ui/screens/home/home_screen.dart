import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/ui/screens/camera_screen.dart';
import 'package:caonalyzer/ui/screens/home/partials/gallery_view.dart';
import 'package:caonalyzer/ui/screens/home/partials/main_view.dart';
import 'package:caonalyzer/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String message = '';
  bool isBusy = false;
  int viewIndex = 0;
  List<Widget> views = [
    const MainView(),
    const GalleryView(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(kAppName),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: buildView(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToCamera,
          label: const Text('Camera'),
          icon: const Icon(Icons.camera),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: viewIndex,
          onTap: (index) {
            setState(() {
              viewIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
          ],
        )
      ),
    );
  }

  Widget buildView() {
    return views[viewIndex];
  }

  void navigateToCamera() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const CameraScreen(),
    ));
  }
}
