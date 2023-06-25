import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
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
  late final HomeBloc homeBloc;
  @override
  void initState() {
    super.initState();

    homeBloc = BlocProvider.of<HomeBloc>(context);
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ));
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final initialState = state as HomeInitial;

          switch (initialState.tab) {
            case HomeTab.home:
              return const Center(child: Text('Home'));
            case HomeTab.gallery:
              return const GalleryFragment();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final initialState = state as HomeInitial;
          return NavigationBar(
            selectedIndex: initialState.tab.index,
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
            onDestinationSelected: (index) {
              homeBloc.add(HomeTabChangedEvent(
                tab: HomeTab.values[index],
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final batchConfirmationBloc = BatchConfirmationBloc();
          final cameraBloc = CameraBloc(mode: CameraCaptureMode.batch);
          bool isFirstCapture = true;
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: batchConfirmationBloc),
                BlocProvider.value(value: cameraBloc),
              ],
              child: CameraPage(
                mode: CameraCaptureMode.batch,
                onCapture: (path) {
                  if (isFirstCapture) {
                    batchConfirmationBloc.add(BatchConfirmationStarted());
                    isFirstCapture = false;
                  }

                  batchConfirmationBloc.add(
                    BatchConfirmationImageAdded(imagePath: path),
                  );
                },
              ),
            ),
          ));
        },
        label: const Text('Camera'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
