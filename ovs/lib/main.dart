import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/whitelist_provider.dart';
import 'providers/election_provider.dart';
import 'providers/voting_provider.dart';
import 'providers/analytics_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Cloud Firestore
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WhitelistProvider()),
        ChangeNotifierProvider(create: (_) => ElectionProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: const SmartVoteApp(),
    ),
  );
}

class SmartVoteApp extends StatelessWidget {
  const SmartVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
