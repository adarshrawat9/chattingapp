
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/user_model.dart';
import '../services/base_repository.dart';

class ContactRepository extends BaseRepository{
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<bool> requestContactPermission () async {
    PermissionStatus status = await Permission.contacts.status;

    if(status.isDenied){
      status = await Permission.contacts.request();
    }

    return status.isGranted ;
  }

  Future<List<Map<String , dynamic>>> getRegisteredContacts() async {
    try{

      bool hasPermission = await requestContactPermission();

      if(!hasPermission){
        print("Error : permission not granted ");

        return [];
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true ,
        withPhoto: true,
      );

      final phoneNumbers = contacts.where(
          (contact) => contact.phones.isNotEmpty)
          .map((contact) => {
        "name" : contact.displayName,
        "phoneNumber" : contact.phones.first.number.replaceAll(RegExp(r'[^\d+]') , ''),
        "photo" : contact.photo,
      }).toList();

      final userSnapshot = await firestore.collection("users").get();

      final registeredUser = userSnapshot.docs.map((docs)=> UserModel.fromFirestore(docs)).toList();

      final matchContacts = phoneNumbers.where((contact){
        final phoneNumber = contact["phoneNumber"];
        return registeredUser.any((user) => user.phoneNumber == phoneNumber);
      }).map((contact){
        final registeredUsers = registeredUser.firstWhere((user)=> user.phoneNumber == contact["phoneNumber"] );
        return {
          "id" : registeredUsers.uid ,
          "name" : contact["name"],
          "phoneNumber" : contact["phoneNumber"],
        };
      }).toList();
      return matchContacts ;
    }
    catch(e){
     print("error getting registered users");

     return [];

    }

  }

}