import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomie_app/config/supabase_config.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'package:roomie_app/providers/location_provider.dart';
import 'package:roomie_app/routes/app_router.dart';
import 'package:roomie_app/theme/app_theme.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:roomie_app/config/stripe_config.dart';
import 'package:roomie_app/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Inicializar Stripe
  Stripe.publishableKey =
      'pk_test_51SpXPI1Zzf1hLpXtcDcdJ5vNyTFWw63UV99SqKvSTiLUJVM3RDgPQOW9xBDHfQHBvHpZFREiaBmm6BWziwoZk7XR00azPK9VVZ';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
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
            title: 'Roomie',
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
