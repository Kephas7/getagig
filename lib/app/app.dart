import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/routes/app_router.dart';
import 'package:getagig/app/theme/app_theme.dart';
import 'package:getagig/app/theme/theme_viewmodel.dart';
import 'package:getagig/core/services/push_service.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Initialize push service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PushService.init(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeViewModelProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
