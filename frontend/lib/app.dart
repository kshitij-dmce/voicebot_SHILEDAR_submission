import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      // Define your routes here
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(), // Replace with your home screen
      ),
    ],
  );
});

class VoxGenieApp extends ConsumerWidget {
  const VoxGenieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'VoxGenie',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // Your theme configuration
          ),
          routerConfig: router,
        );
      },
    );
  }
}