import 'package:camera/camera.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    cameras.value = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cao-nalyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
