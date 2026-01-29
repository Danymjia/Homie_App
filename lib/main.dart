import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'package:roomie_app/providers/location_provider.dart';
import 'package:roomie_app/routes/app_router.dart';
import 'package:roomie_app/theme/app_theme.dart';
import 'package:roomie_app/providers/theme_provider.dart';

import 'package:roomie_app/screens/splash/splash_screen.dart';

import 'package:roomie_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const SplashScreen());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Homie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: themeProvider.themeData,
            themeMode:
                ThemeMode.dark, // Enforced dark mode based on previous config
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
