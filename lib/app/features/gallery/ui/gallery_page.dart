import 'package:caonalyzer/app/features/batch_confirmation/bloc/batch_confirmation_bloc.dart';
import 'package:caonalyzer/app/features/camera/bloc/camera_bloc.dart';
import 'package:caonalyzer/app/features/camera/ui/camera_page.dart';
import 'package:caonalyzer/app/features/gallery/ui/gallery_fragment.dart';
import 'package:caonalyzer/app/features/settings/ui/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/logos/logos_transparent_cropped.png'),
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
      body: const GalleryFragment(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => BatchConfirmationBloc(),
              child: const CameraPage(mode: CameraCaptureMode.batch),
            ),
          ));
        },
        label: const Text('Camera'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}
