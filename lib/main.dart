import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kitt_plus/pages/chat.dart';
import 'services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:kitt_plus/services/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MyApp(
      appTheme: AppTheme(),
    ),
  );
}

// This function is used to update the page title
void setPageTitle(String title, BuildContext context) {
  SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
    label: title,
    primaryColor: Theme.of(context).primaryColor.value, // This line is required
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appTheme,
  });

  final AppTheme appTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      title: 'Made by | Kitt, LLC',
      home: const ChatPage(),
    );
  }
}
