import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:caonalyzer/app/features/home/ui/home_page.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.init();

  runApp(const CaonalyzerApp());
}

class CaonalyzerApp extends StatelessWidget {
  const CaonalyzerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cao-nalyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GalleryBloc()..add(GalleryInitialEvent()),
          )
        ], child: const HomePage(),
      ),
    );
  }
}
