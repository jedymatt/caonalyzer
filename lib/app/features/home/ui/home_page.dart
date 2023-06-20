import 'package:caonalyzer/app/features/camera/ui/camera_page.dart';
import 'package:caonalyzer/app/features/gallery/ui/gallery_fragment.dart';
import 'package:caonalyzer/app/features/settings/ui/settings_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cao-nalyzer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ));
            },
          ),
        ],
      ),
      body: Builder(builder: (context) {
        switch (selectedTab) {
          case 0:
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Text('Home')),
            );
          case 1:
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: GalleryFragment(),
            );
        }

        return const Center(child: Text('404 Not Found'));
      }),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            selectedTab = value;
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const CameraPage(),
          ));
        },
        label: const Text('Camera'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
