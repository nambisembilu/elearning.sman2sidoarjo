import 'package:elearning_sman2sidoarjo/core/network/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/features/auth/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// load .env
  // await dotenv.load(fileName: ".env");

  /// 🔥 INIT SUPABASE (WAJIB)
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      // 👈 WAJIB untuk Riverpod
      child: SMAN2ElearningApp(),
    ),
  );
}

class SMAN2ElearningApp extends StatelessWidget {
  const SMAN2ElearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: MaterialApp.router(
        title: 'E-Learning SMAN 2 Sidoarjo',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
