import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

Future<void> main() async {
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
    return GetMaterialApp(
      title: 'Cao-nalyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
