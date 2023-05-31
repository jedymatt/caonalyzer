import 'package:flutter/material.dart';

import '../globals.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          // host IP or domain name
          ListTile(
            title: const Text('IP or domain name'),
            subtitle: Text(host),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // modal
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
