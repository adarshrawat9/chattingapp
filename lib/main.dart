import 'package:chattingapp/data/repositories/chat_repository.dart';
import 'package:chattingapp/logic/cubits/auth/auth_cubit.dart';
import 'package:chattingapp/logic/cubits/auth/auth_state.dart';
import 'package:chattingapp/logic/observer/app_life_cycle_observer.dart';
import 'package:chattingapp/presentation/home/home_screen.dart';
import 'package:chattingapp/presentation/screens/auth/Login_screen.dart';
import 'package:chattingapp/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/theme/app_theme.dart';
import 'data/services/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifeCycleObserver _lifeCycleObserver;

  @override
  void dispose() {
    if (_lifeCycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifeCycleObserver);
    }
    super.dispose();
  }



  @override
  void initState() {
    getit<AuthCubit>().stream.listen((state){
      if(state.status == AuthStatus.authenticated && state.user!= null){
        _lifeCycleObserver = AppLifeCycleObserver(userId: state.user!.uid,
            chatRepository: getit<ChatRepository>());
         WidgetsBinding.instance.addObserver(_lifeCycleObserver);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'Messenger App',
        theme: AppTheme.lightTheme,
        navigatorKey: getit<AppRouter>().navigatorKey,


        home: BlocBuilder<AuthCubit , AuthState>(
          bloc: getit<AuthCubit>(),
            builder: (context , state){
            if(state.status == AuthStatus.initial){
              return Scaffold(
                body:  Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if(state.status == AuthStatus.authenticated && state.user != null){
              return const HomeScreen();
            }
            return const LoginScreen();

        }),
      ),
    );
  }
}
