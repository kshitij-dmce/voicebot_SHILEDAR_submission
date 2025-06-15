import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/speech_service.dart';
import 'services/tts_service.dart';
import 'ui/home_page.dart'; // Make sure this contains your home page widget

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create AppTheme provider
    final appTheme = AppTheme();
    
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AppTheme>(
              create: (context) => appTheme,
            ),
            ChangeNotifierProvider<SpeechService>(
              create: (context) => SpeechService(),
            ),
            ChangeNotifierProvider<TTSService>(
              create: (context) => TTSService(),
            ),
          ],
          child: Consumer<AppTheme>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'VoxGenie',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: const HomePage(), // Make sure this matches your actual home widget name
              );
            }
          ),
        );
      },
    );
  }
}