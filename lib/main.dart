import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/services/auth_service.dart';
import 'package:mealtime/screens/wrapper.dart';
import 'package:mealtime/providers/theme_provider.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/providers/language_provider.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz show initializeTimeZones;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => HouseholdProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, LanguageProvider, HouseholdProvider>(
      builder: (context, themeProvider, languageProvider, householdProvider, child) {
        // Material Design 3 Expressive colors
        const Color primarySeedColor = Color(0xFF6750A4); // Vibrant purple

        final TextTheme appTextTheme = TextTheme(
          displayLarge: GoogleFonts.inter(
            fontSize: 57, 
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 45, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 36, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 32, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 28, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 24, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 22, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12, 
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11, 
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        );

        final ThemeData lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primarySeedColor,
            brightness: Brightness.light,
            primary: const Color(0xFF6750A4),
            secondary: const Color(0xFF625B71),
            tertiary: const Color(0xFF7D5260),
            surface: const Color(0xFFFFFBFE),
            surfaceContainerHighest: const Color(0xFFE7E0EC),
            onSurface: const Color(0xFF1C1B1F),
            onSurfaceVariant: const Color(0xFF49454F),
            outline: const Color(0xFF79747E),
            error: const Color(0xFFBA1A1A),
            onError: const Color(0xFFFFFFFF),
          ),
          textTheme: appTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: primarySeedColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 22, 
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            surfaceTintColor: Colors.transparent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primarySeedColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              textStyle: GoogleFonts.inter(
                fontSize: 14, 
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              elevation: 0,
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: primarySeedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Color(0xFFFFFBFE),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFE7E0EC),
            selectedColor: primarySeedColor,
            labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        final ThemeData darkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primarySeedColor,
            brightness: Brightness.dark,
            primary: const Color(0xFFD0BCFF),
            secondary: const Color(0xFFCCC2DC),
            tertiary: const Color(0xFFEFB8C8),
            surface: const Color(0xFF1C1B1F),
            surfaceContainerHighest: const Color(0xFF49454F),
            onSurface: const Color(0xFFE6E1E5),
            onSurfaceVariant: const Color(0xFFCAC4D0),
            outline: const Color(0xFF938F99),
            error: const Color(0xFFFFB4AB),
            onError: const Color(0xFF690005),
          ),
          textTheme: appTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1C1B1F),
            foregroundColor: const Color(0xFFE6E1E5),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 22, 
              fontWeight: FontWeight.w400,
              color: const Color(0xFFE6E1E5),
            ),
            surfaceTintColor: Colors.transparent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF1C1B1F),
              backgroundColor: const Color(0xFFD0BCFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              textStyle: GoogleFonts.inter(
                fontSize: 14, 
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              elevation: 0,
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD0BCFF),
              foregroundColor: const Color(0xFF1C1B1F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
          cardTheme: const CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Color(0xFF1C1B1F),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFF49454F),
            selectedColor: const Color(0xFFD0BCFF),
            labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        return StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
          child: MaterialApp(
            title: 'MealTime',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('pt', 'BR'),
              Locale('es', 'ES'),
            ],
            locale: languageProvider.currentLocale,
            home: const Wrapper(),
          ),
        );
      },
    );
  }
}
