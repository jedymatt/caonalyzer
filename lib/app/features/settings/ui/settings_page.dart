import 'package:caonalyzer/app/features/settings/bloc/settings_bloc.dart';
import 'package:caonalyzer/app/data/enums/preferred_mode.dart';
import 'package:caonalyzer/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsBloc settingsBloc;

  @override
  void initState() {
    super.initState();
    settingsBloc = SettingsBloc()..add(SettingsStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        bloc: settingsBloc,
        builder: (context, state) {
          if (state is! SettingsLoadSuccess) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              // toggle online or offline mode
              SwitchListTile(
                title: const Text('Online Inference'),
                value: state.preferredMode == PreferredMode.online,
                onChanged: (value) {
                  settingsBloc.add(SettingsPreferredModeChanged(
                    value ? PreferredMode.online : PreferredMode.offline,
                  ));
                  settingsBloc.add(SettingsPreferredModeSubmitted());
                },
              ),
              // Server, freely switch inputs for (host and port) or (domain)
              ListTile(
                title: const Text('Server'),
                subtitle: const Text('The server to use for online mode'),
                trailing: const Icon(Icons.chevron_right),
                enabled: state.preferredMode == PreferredMode.online,
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Server'),
                      content: BlocProvider.value(
                        value: settingsBloc,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ServerHostInput(initialValue: state.host),
                            _ServerPortInput(initialValue: state.port),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            settingsBloc.add(SettingsServerSubmitted());
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                  settingsBloc.add(SettingsStarted());
                },
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: kAppName,
                    applicationVersion:
                        '${Globals.appVersion}+${Globals.buildNumber}',
                    children: const [
                      Text(
                        'This app is made by UMTC CS Students with ❤️.',
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServerHostInput extends StatelessWidget {
  const _ServerHostInput({this.initialValue = ''});

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: const InputDecoration(
        labelText: 'Host',
      ),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.url,
      autofocus: true,
      onChanged: (value) {
        BlocProvider.of<SettingsBloc>(context)
            .add(SettingsServerHostChanged(value));
      },
    );
  }
}

class _ServerPortInput extends StatelessWidget {
  const _ServerPortInput({this.initialValue = ''});

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: const InputDecoration(
        labelText: 'Port',
      ),
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        BlocProvider.of<SettingsBloc>(context)
            .add(SettingsServerPortChanged(value));
      },
      onFieldSubmitted: (value) {
        BlocProvider.of<SettingsBloc>(context).add(SettingsServerSubmitted());
        Navigator.of(context).pop();
      },
    );
  }
}
