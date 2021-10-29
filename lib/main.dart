import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:selfaccount/core/features/auth_controller_view/auth_controller_view.dart';
import 'package:selfaccount/core/init/helpers/provider/home_viev_extension_provider.dart';
import 'package:selfaccount/core/init/helpers/service/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeViewManagerProvider()),
      ChangeNotifierProvider(create: (_) => FirebaseService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akont',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthController(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''), // English, no country code
      ],
    );
  }
}
