import 'dart:async';
import 'dart:ffi';

import 'package:chattingapp/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chattingapp/logic/cubits/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState>{
 final AuthRepository _authRepository ;
 StreamSubscription<User?>? _authStateSubscription ;

  AuthCubit({
   required AuthRepository authrepository,
}): _authRepository = authrepository ,super(AuthState()){
    _init();
  }
void _init(){
    emit(state.copyWith(status:  AuthStatus.initial));

    _authStateSubscription = _authRepository.authStateChange.listen((user) async {
      if(user!= null){
        try{
          final userData  = await _authRepository.getUserData(user.uid);
          emit(state.copyWith(
              status: AuthStatus.authenticated , user: userData));
        }
        catch(e){
          emit(state.copyWith(status: AuthStatus.error , error: e.toString()));
        }
      }
      else{
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    });
}

Future<void> signIn({
   required String email,
  required String password,
}) async {
    try{
      emit(state.copyWith(status: AuthStatus.loading));

      final user  = await _authRepository.signIn(
          email: email,
          password: password);
       emit( state.copyWith(
           status: AuthStatus.authenticated,
           user: user));
    }
    catch(e){
      emit(state.copyWith(status: AuthStatus.error , error: e.toString()));
    }
    }


 Future<void> signUp({
   required String email,
   required String password,
   required String  fullName,
   required String userName,
   required String phoneNumber,
 }) async {
   try{
     emit(state.copyWith(status: AuthStatus.loading));

     final user  = await _authRepository.signUp(
         fullName: fullName,
         userName: userName,
         email: email,
         phoneNumber: phoneNumber,
         password: password);
     emit( state.copyWith(
         status: AuthStatus.authenticated,
     user: user));
   }
   catch(e){
     emit(state.copyWith(status: AuthStatus.error , error: e.toString()));
   }
 }

 Future<void> signOut()async{
    try{
      await _authRepository.signOut();
      emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user : null));
    }
    catch(e){
      emit(state.copyWith(status: AuthStatus.error , error:  e.toString()));
    }
 }
}

