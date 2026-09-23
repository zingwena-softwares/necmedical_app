import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'widgets/connectivity_gate.dart';

void main() {
  runApp(const ProviderScope(child: NecMedicalApp()));
}

class NecMedicalApp extends StatelessWidget {
  const NecMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF0B4F6C); // adjust to match NEC Medical brand color
    const fontFamily = 'Poppins';

    return MaterialApp(
      title: 'Medical NEC',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
        useMaterial3: true,
        fontFamily: fontFamily,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        dialogTheme: const DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22)))),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: fontFamily,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        dialogTheme: const DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22)))),
      ),
      home: const SplashScreen(),
      builder: (context, child) => ConnectivityGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
