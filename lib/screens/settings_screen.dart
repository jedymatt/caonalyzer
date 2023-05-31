import 'package:flutter/material.dart';

import '../globals.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool onlineMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          // toggle online or offline mode
          SwitchListTile(
            title: const Text('Online mode'),
            subtitle: const Text('Use a server to run inference'),
            value: onlineMode,
            onChanged: (value) {},
          ),
          ListTile(
            title: const Text('IP or domain name'),
            subtitle: Text(host),
            trailing: const Icon(Icons.chevron_right),
            enabled: onlineMode,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('IP or domain name'),
                    content: TextField(
                      controller: TextEditingController(text: host),
                      onChanged: (value) {
                        host = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
