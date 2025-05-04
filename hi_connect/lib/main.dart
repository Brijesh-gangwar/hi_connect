import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hi_connect/config/theme/app_theme.dart';
import 'package:hi_connect/data/repositories/chat_repository.dart';
import 'package:hi_connect/data/services/service_locator.dart';
import 'package:hi_connect/logic/cubits/auth/auth_cubit.dart';
import 'package:hi_connect/logic/cubits/auth/auth_state.dart';
import 'package:hi_connect/logic/observer/app_life_cycle_observer.dart';
import 'package:hi_connect/presentation/home/home_screen.dart';
import 'package:hi_connect/presentation/screens/auth/login_screen.dart';
import 'package:hi_connect/router/app_router.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifeCycleObserver _lifeCycleObserver;

  @override
  void initState() {
    getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        _lifeCycleObserver = AppLifeCycleObserver(
            userId: state.user!.uid, chatRepository: getIt<ChatRepository>());
      }
      WidgetsBinding.instance.addObserver(_lifeCycleObserver);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Messenger App',
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == AuthStatus.authenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
