import 'package:caonalyzer/app/features/home/ui/home_page.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return GetMaterialApp(
      title: 'Cao-nalyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
