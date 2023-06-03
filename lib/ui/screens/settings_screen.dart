import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';

import 'package:caonalyzer/enums/preferred_mode.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            value: preferredMode.value == PreferredMode.online,
            onChanged: null,
            // onChanged: (value) {
            //   setState(() {
            //     preferredMode.value =
            //         value ? PreferredMode.online : PreferredMode.offline;
            //   });
            // },
          ),
          ListTile(
            title: const Text('Host'),
            subtitle: Text(host.value),
            trailing: const Icon(Icons.chevron_right),
            enabled: preferredMode.value == PreferredMode.online,
            onTap: () {
              String hostInput = host.value;

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Host'),
                    content: TextField(
                      controller: TextEditingController(text: hostInput),
                      onChanged: (value) {
                        hostInput = value;
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
                          setState(() {
                            host.value = hostInput;
                          });

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
