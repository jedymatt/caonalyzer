import 'package:caonalyzer/app/features/theme/app_theme.dart';
import 'package:caonalyzer/app/features/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.brightness_4),
            value: context.read<ThemeBloc>().state.theme.isDark,
            onChanged: (value) {
              context.read<ThemeBloc>().add(
                    ThemeChanged(
                      value
                          ? context.read<ThemeBloc>().state.theme.dark
                          : context.read<ThemeBloc>().state.theme.light,
                    ),
                  );
            },
          ),
          // select between primary, blue, and orange
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Primary Color'),
            subtitle: const Text('The primary color of the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final currentTheme = context.read<ThemeBloc>().state.theme;
              showDialog<AppTheme>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Select a primary color'),
                  children: [
                    // default
                    RadioListTile<AppTheme>(
                      title: const Text('Default'),
                      value: currentTheme.isDark
                          ? AppTheme.darkPrimary
                          : AppTheme.lightPrimary,
                      groupValue: currentTheme,
                      onChanged: (value) => Navigator.of(context).pop(value),
                    ),
                    RadioListTile<AppTheme>(
                      title: const Text('Blue'),
                      value: currentTheme.isDark
                          ? AppTheme.darkBlue
                          : AppTheme.lightBlue,
                      groupValue: currentTheme,
                      onChanged: (value) => Navigator.of(context).pop(value),
                    ),
                    RadioListTile<AppTheme>(
                      title: const Text('Orange'),
                      value: currentTheme.isDark
                          ? AppTheme.darkOrange
                          : AppTheme.lightOrange,
                      groupValue: currentTheme,
                      onChanged: (value) => Navigator.of(context).pop(value),
                    ),
                    RadioListTile<AppTheme>(
                      title: const Text('Green'),
                      value: currentTheme.isDark
                          ? AppTheme.darkGreen
                          : AppTheme.lightGreen,
                      groupValue: currentTheme,
                      onChanged: (value) => Navigator.of(context).pop(value),
                    ),
                    RadioListTile<AppTheme>(
                      title: const Text('Red'),
                      value: currentTheme.isDark
                          ? AppTheme.darkRed
                          : AppTheme.lightRed,
                      groupValue: currentTheme,
                      onChanged: (value) => Navigator.of(context).pop(value),
                    ),
                    // yellow
                    RadioListTile<AppTheme>(
                      title: const Text('Yellow'),
                      value: currentTheme.isDark
                          ? AppTheme.darkYellow
                          : AppTheme.lightYellow,
                      groupValue: currentTheme,
                      onChanged: (value) => Navigator.of(context).pop(value),
                    ),
                  ],
                ),
              ).then((value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(ThemeChanged(value));
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
