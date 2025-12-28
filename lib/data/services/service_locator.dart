import 'package:chattingapp/data/repositories/auth_repository.dart';
import 'package:chattingapp/data/repositories/contact_repository.dart';
import 'package:chattingapp/firebase_options.dart';
import 'package:chattingapp/logic/cubits/auth/auth_cubit.dart';
import 'package:chattingapp/logic/cubits/chat/chat_cubit.dart';
import 'package:chattingapp/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../repositories/chat_repository.dart';

final getit = GetIt.asNewInstance();

Future<void> setupServiceLocator()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  getit.registerLazySingleton(()=>AppRouter());
  getit.registerLazySingleton<FirebaseFirestore>(()=> FirebaseFirestore.instance);
  getit.registerLazySingleton<FirebaseAuth>(()=> FirebaseAuth.instance);
  getit.registerLazySingleton(()=>AuthRepository());
  getit.registerLazySingleton(()=>AuthCubit(authrepository: AuthRepository()));
  getit.registerLazySingleton(()=>ContactRepository());
  getit.registerFactory(()=>ChatRepository());
  getit.registerLazySingleton(()=>ChatCubit(chatRepository: ChatRepository(), currentUserId: getit<FirebaseAuth>().currentUser!.uid));
}