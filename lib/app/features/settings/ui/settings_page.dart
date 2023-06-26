import 'package:caonalyzer/app/features/settings/bloc/settings_bloc.dart';
import 'package:caonalyzer/enums/preferred_mode.dart';
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
      body: ListView(
        children: [
          // options online or offline mode
          ListTile(
            title: const Text('Preferred Mode'),
            subtitle: const Text('The preferred mode to use'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Preferred Mode'),
                  content: BlocBuilder<SettingsBloc, SettingsState>(
                    bloc: settingsBloc,
                    builder: (context, state) {
                      if (state is! SettingsLoadSuccess) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<PreferredMode>(
                            title: const Text('Offline'),
                            value: PreferredMode.offline,
                            groupValue: state.preferredMode,
                            onChanged: (value) {
                              settingsBloc.add(
                                SettingsPreferredModeChanged(value!),
                              );
                            },
                          ),
                          RadioListTile<PreferredMode>(
                            title: const Text('Online'),
                            value: PreferredMode.online,
                            groupValue: state.preferredMode,
                            onChanged: (value) {
                              settingsBloc.add(
                                SettingsPreferredModeChanged(value!),
                              );
                            },
                          ),
                        ],
                      );
                    },
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
                        settingsBloc.add(SettingsPreferredModeSubmitted());
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
          // Server, freely switch inputs for (host and port) or (domain)
          ListTile(
            title: const Text('Server'),
            subtitle: const Text('The server to use for online mode'),
            trailing: const Icon(Icons.chevron_right),
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
                        const _ServerHostInput(),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Port',
                          ),
                          onChanged: (value) {
                            Globals.port.value = value;
                          },
                        ),
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
        ],
      ),
    );
  }
}

class _ServerHostInput extends StatelessWidget {
  const _ServerHostInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) {
        if (previous is! SettingsLoadSuccess &&
            current is! SettingsLoadSuccess) {
          return false;
        }

        return (previous as SettingsLoadSuccess).host !=
            (current as SettingsLoadSuccess).host;
      },
      builder: (context, state) {
        if (state is! SettingsLoadSuccess) {
          return const SizedBox.shrink();
        }

        return TextFormField(
          initialValue: state.host,
          decoration: const InputDecoration(
            labelText: 'Host',
          ),
          onChanged: (value) {
            context.read<SettingsBloc>().add(SettingsServerHostChanged(value));
          },
        );
      },
    );
  }
}
