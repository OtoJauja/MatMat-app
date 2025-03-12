import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';
import 'Services/mission_provider_calm.dart';
import 'Services/mission_provider_fast.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/Services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('lv')],
      path: 'assets/i18n', // Directory containing translation files
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionsProviderCalm()),
        ChangeNotifierProvider(create: (_) => MissionsProviderFast()),
      ],
      child: MaterialApp(
        key: ValueKey(context.locale.toString()), // Forces rebuild on locale change
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Mali'),
        // EasyLocalization properties
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData) {
              return const MainNavigation();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}