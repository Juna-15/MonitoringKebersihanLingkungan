import 'package:ecoclean_app/firebase_options.dart';
import 'package:ecoclean_app/screens/auth/sign_in_screen.dart';
import 'package:ecoclean_app/screens/navigation_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Notifier global untuk Dark Mode (Personalisasi)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EcoCleanApp());
}

class EcoCleanApp extends StatelessWidget {
  const EcoCleanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "EcoClean",
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          // Monitoring status login secara Real-Time
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // Jika ada data user, berarti sedang login
              if (snapshot.hasData && snapshot.data != null) {
                return const NavigationWrapper();
              }
              // Jika tidak ada data, berarti belum login
              return const SignInScreen();
            },
          ),
        );
      },
    );
  }
}
