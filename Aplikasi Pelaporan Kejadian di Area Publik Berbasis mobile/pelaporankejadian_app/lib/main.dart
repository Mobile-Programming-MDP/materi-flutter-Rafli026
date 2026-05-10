import 'package:flutter/material.dart';

import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/add_post_screen.dart';
import 'screens/detail_post_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'state/app_state.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PelaporanKejadianApp());
}

class PelaporanKejadianApp extends StatefulWidget {
  const PelaporanKejadianApp({super.key});

  @override
  State<PelaporanKejadianApp> createState() => _PelaporanKejadianAppState();
}

class _PelaporanKejadianAppState extends State<PelaporanKejadianApp> {
  final appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return AppStateScope(
          appState: appState,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: appState.themeMode,
            title: 'Pelaporan Kejadian',
            initialRoute: appState.currentUser == null
                ? SignInScreen.route
                : HomeScreen.route,
            routes: {
              SignInScreen.route: (_) => SignInScreen(appState: appState),
              SignUpScreen.route: (_) => SignUpScreen(appState: appState),
              HomeScreen.route: (_) => HomeScreen(appState),
              AddPostScreen.route: (_) => AddPostScreen(appState: appState),
            },
            onGenerateRoute: (settings) {
              if (settings.name == DetailPostScreen.route) {
                final args = settings.arguments as Map<String, dynamic>?;
                final postId = args?['postId'] as String?;
                if (postId == null) {
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('postId belum ada')),
                    ),
                  );
                }
                return MaterialPageRoute(
                  builder: (_) => DetailPostScreen(postId: postId),
                );
              }

              if (settings.name == MapScreen.route) {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => MapScreen(
                    initialLat: (args?['lat'] as double?) ?? 0,
                    initialLng: (args?['lng'] as double?) ?? 0,
                    title: args?['title'] as String?,
                  ),
                );
              }

              return null;
            },
          ),
        );
      },
    );
  }
}
