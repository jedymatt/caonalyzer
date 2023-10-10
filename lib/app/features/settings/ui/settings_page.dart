import 'package:caonalyzer/app/features/theme/ui/theme_page.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ThemePage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: kAppName,
                applicationVersion:
                    '${Globals.appVersion}+${Globals.buildNumber}',
                children: const [
                  Text(
                    'This app is made by UMTC CS Students with ❤️',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
