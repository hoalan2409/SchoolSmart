import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/students_provider.dart';
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'constants/app_constants.dart';
import 'services/api_service.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize API service
    ApiService.initialize();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Internationalization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('vi'), // Vietnamese
            ],
            locale: languageProvider.currentLocale,
            
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: AppConstants.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
            builder: (context, child) => child!,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isAuthenticated ? HomeScreen() : LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
