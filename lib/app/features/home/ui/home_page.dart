import 'package:caonalyzer/app/features/camera/ui/camera_page.dart';
import 'package:caonalyzer/app/features/gallery/ui/gallery_fragment.dart';
import 'package:caonalyzer/app/features/home/bloc/home_bloc.dart';
import 'package:caonalyzer/app/features/settings/ui/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc homeBloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    homeBloc.add(HomeInitialEvent());
  }

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
              homeBloc.add(HomeNavigateToSettingsEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        bloc: homeBloc,
        listenWhen: (previous, current) => current is HomeActionState,
        buildWhen: (previous, current) => current is! HomeActionState,
        listener: (context, state) {
          if (state is HomeNavigateToCameraActionState) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CameraPage(),
            ));
          } else if (state is HomeNavigateToSettingsActionState) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ));
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case HomeInitial:
              return const Center(child: Text('Home'));
            case HomeTabChangedToGallery:
              return const GalleryFragment();
          }
          return const Center(child: Text('Default'));
        },
      ),
      bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
        bloc: homeBloc,
        builder: (context, state) {
          return NavigationBar(
            selectedIndex: state is HomeTabChangedToGallery ? 1 : 0,
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
              if (value == 0) {
                homeBloc.add(HomeInitialEvent());
              } else if (value == 1) {
                homeBloc.add(HomeChangeTabToGalleryEvent());
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          homeBloc.add(HomeNavigateToCameraEvent());
        },
        label: const Text('Camera'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
