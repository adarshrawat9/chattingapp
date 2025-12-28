import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:chattingapp/data/models/user_model.dart';
import 'package:chattingapp/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository{

  Stream<User?> get authStateChange => auth.authStateChanges();

  Future<UserModel> signUp({
    required String fullName,
    required String userName,
    required String email,
    required String phoneNumber,
    required String password,
})async{
    try {
      final formattedPhoneNumber =phoneNumber.replaceAll(RegExp(r'\s+'), "".trim());
      final emailExist = await checkEmailExists(email);
      if(emailExist){
        throw "An account with same email exists";
      }
      final phoneExists = await checkPhoneExists(phoneNumber);
      if(phoneExists){
        throw "An account with same phone number exists";
      }
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw"failed to create user";
      }

      final user = UserModel(
          uid: userCredential.user!.uid,
          userName: userName,
          fullName: fullName,
          email: email,
          phoneNumber: formattedPhoneNumber,
      );
      await saveUserData(user) ;
      return user ;
    }
    catch(e){
      developer.log(e.toString()) ;
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
   try{
     await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: email,
         password: "thisisdummypassword123");
     final currentUser = FirebaseAuth.instance.currentUser;
     if(currentUser != null ){
       await currentUser.delete();
       print("a dummy user was created and deleted");
     }
     return false;
   }
   on FirebaseAuthException catch(e){
     if(e.code == 'email-already-in-use'){
       print("email is already used");
       return true;
     }
     else if (e.code == 'invalid-email'){
       print("Invalid email format : ${email}");
       return false;
     }
     else{
       print("an unexpected error was found :${e.code} - ${e.message}");
       return false ;
     }
   }
   catch(e){
     print("an unexpected error occured ${e.toString()}");
     return false;
   }
  }
  Future<bool> checkPhoneExists (String newPhoneNo) async {
    try{
      final formattedPhoneNumber =newPhoneNo.replaceAll(RegExp(r'\s+'), "".trim());
      final  QuerySnapshot result = await firestore.collection("users").where("phoneNumber" , isEqualTo: formattedPhoneNumber).limit(1).get();
      if(result.docs.isNotEmpty){
        print("the phone number $newPhoneNo exists in database");
        return true;
      }
      else{
        print("the phone number $newPhoneNo doesnot exist");
        return false;
      }
    }
    catch(e){
      print("an exception occured ${e.toString()}");
      return false;
    }

  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  })async{
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw"user not found";
      }
      final userData = await getUserData(userCredential.user!.uid);
      return userData ;
    }
    catch(e){
      developer.log(e.toString()) ;
      rethrow;
    }
  }
  Future<void> saveUserData(UserModel user)async{
    try {

      await firestore.collection("users").doc(user.uid).set(user.toMap());
      print('User data saved successfully!');

    } catch (e) {
      throw "failed to save user data" ;
    }
  }
  Future<void> signOut()async{
   await auth.signOut();
  }
  Future<UserModel> getUserData(String uid)async{
    try {
      final doc = await firestore.collection("users").doc(uid).get();

      return UserModel.fromFirestore(doc);
    } catch (e) {

      throw "Failed to get user data: $e" ;
    }
  }
}

