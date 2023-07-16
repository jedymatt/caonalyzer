import 'package:caonalyzer/app/features/gallery/bloc/gallery_bloc.dart';
import 'package:caonalyzer/app/features/gallery/ui/gallery_page.dart';
import 'package:caonalyzer/app/features/home/bloc/home_bloc.dart';
import 'package:caonalyzer/app/features/theme/app_theme.dart';
import 'package:caonalyzer/app/features/theme/bloc/theme_bloc.dart';
import 'package:caonalyzer/globals.dart';
import 'package:caonalyzer/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.init();
  await Hive.initFlutter();

  final settingsBox = await Hive.openBox('settings');
  final themeIndex = settingsBox.get('theme', defaultValue: 0);

  setupLocator();

  Bloc.observer = AppBlocObserver();

  runApp(App(
    initialTheme: AppTheme.values[themeIndex],
  ));
}

class App extends StatelessWidget {
  const App({
    super.key,
    this.initialTheme = AppTheme.lightPrimary,
  });

  final AppTheme initialTheme;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GalleryBloc()..add(GalleryStarted()),
        ),
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(
          create: (context) => ThemeBloc(initialTheme: initialTheme),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Cao-nalyzer',
            theme: state.theme.themeData,
            home: const GalleryPage(),
          );
        },
      ),
    );
  }
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    debugPrint('${bloc.runtimeType} closed');
    super.onClose(bloc);
  }
}
