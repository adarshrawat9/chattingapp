import 'package:chattingapp/data/models/chat_messaging.dart';
import 'package:chattingapp/data/models/chat_room_model.dart';
import 'package:chattingapp/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/encryption_helper.dart';
import '../../core/utils/storage_helper.dart';
import '../models/user_model.dart';

class ChatRepository extends BaseRepository{

  CollectionReference get _chatRooms => firestore.collection("chatRooms");
  CollectionReference getchatRoomMessages(String chatRoomId) => firestore.collection("chatRooms").doc(chatRoomId).collection("messages");

  Future<ChatRoomModel> getOrCreateChatRoom(String currentUserId , String otherUserId)async{
    final users = [currentUserId , otherUserId]..sort();
    final chatRoomId = users.join("_");

    final chatRoomDoc = await _chatRooms.doc(chatRoomId).get();

    if(chatRoomDoc.exists){
      final room = ChatRoomModel.fromFirestore(chatRoomDoc);

      if(room.encryptionKey != null && room.encryptionKey!.isNotEmpty){
        await SecureStorageHelper.saveAesKey(chatRoomId, room.encryptionKey!);
      }
      return room ;
    }

    final newAesKey = await SecureStorageHelper.generateAesKey();

    await SecureStorageHelper.saveAesKey(chatRoomId, newAesKey);



    final currentUserDoc = await firestore.collection("users").doc(currentUserId).get();
    final otherUserDoc = await firestore.collection("users").doc(otherUserId).get();

    if (!currentUserDoc.exists || !otherUserDoc.exists) {
      throw Exception("Cannot create chat room. User data is missing.");
    }

    final currentUserData = currentUserDoc.data() as Map<String , dynamic>;
    final otherUserData = otherUserDoc.data() as Map<String , dynamic>;

    final participantsName = {
      currentUserId : currentUserData["fullName"].toString() ?? "",
      otherUserId : otherUserData["fullName"].toString() ?? "",
    };

    final chatRoom = ChatRoomModel(
    id: chatRoomId,
    participants: users,
    participantsName: participantsName,
    typingUserId: currentUserId,
    lastReadTime: {
      currentUserId : Timestamp.now(),
      otherUserId : Timestamp.now(),
    },
      encryptionKey: newAesKey,
    );
    await _chatRooms.doc(chatRoomId).set(chatRoom.toMap());
    return chatRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId ,
    required String senderId ,
    required String receiverId ,
    required String content ,
    messageType type = messageType.text,
  })async{
    print("sending message");
    // batch
    final batch = firestore.batch();

    // get message sub collection
    final messageRef = getchatRoomMessages(chatRoomId);
    final DocumentReference messageDoc = messageRef.doc();


    // chat messages
    final message = ChatMessage(
        id: messageDoc.id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        type: type,
        content: content,
        timestamp: Timestamp.now(),
        readBy: [senderId],
    );

    // add message to subcollection
    final encryptedMap = await message.toMap();
    print(" Final encryptedMap types: ${encryptedMap.map((k, v) => MapEntry(k, v.runtimeType))}");
    print(" messageDoc is: ${messageDoc.runtimeType}");
    batch.set(messageDoc, encryptedMap);
    final encryptedLastMessage = await EncryptionHelper.encryptText(content, chatRoomId);


    //update chatroom
    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage" : encryptedLastMessage,
      "lastMessageSenderId" : senderId,
      "lastMessageTime" : Timestamp.now(),
    });
    try {
      await batch.commit();
      print("Message sent successfully");
      await updateMessageStatus(
        chatRoomId: chatRoomId,
        messageId: message.id,
        status: messageStatus.sent,
      );
    } catch (e) {
      print("Failed to send message: $e");
      await updateMessageStatus(
        chatRoomId: chatRoomId,
        messageId: message.id,
        status: messageStatus.notSent,
      );
    }

  }


  Future<void> updateMessageStatus({
    required String chatRoomId,
    required String messageId,
    required messageStatus status,
  }) async {
    try {
      await getchatRoomMessages(chatRoomId).doc(messageId).update({
        "status": status.name,
      });
    } catch (e) {
      print("Error updating message status: $e");
    }
  }

  Future<void> markMessageAsRead({
    required String chatRoomId,
    required String messageId,
    required String userId,
  }) async {
    final messageRef = getchatRoomMessages(chatRoomId).doc(messageId);

    try {
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(messageRef);
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final List<String> readByList = List<String>.from(data['readBy'] ?? []);
          if (!readByList.contains(userId)) {
            readByList.add(userId);
            transaction.update(messageRef, {
              'readBy': readByList,
              'status': messageStatus.read.name,
            });
          }
        }
      });
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }


  Stream<List<ChatMessage>> getMessage(String chatRoomId ,{DocumentSnapshot ? lastDocument})
  {
    var query =  getchatRoomMessages(chatRoomId).orderBy("timestamp" , descending: true).limit(30);

    if(lastDocument != null){
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().asyncMap((snapshot) async {
      final List<Future<ChatMessage>> chatMessageFutures =
      snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
      return await Future.wait(chatMessageFutures);
    });
  }

  Future<List<ChatMessage>> loadMoreMessages(
      { required String chatRoomId,required DocumentSnapshot lastDocument}) async {
    if(lastDocument == null){
      return [];
    }

    Query query = getchatRoomMessages(chatRoomId).orderBy("timestamp" , descending:  true).startAfterDocument(lastDocument).limit(30);
    final QuerySnapshot snapshot = await query.get();

    final List<Future<ChatMessage>> messages = snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();

    return await Future.wait(messages);
  }

  Stream<List<ChatRoomModel>> getChatRooms(String currentUserId){
    return _chatRooms.where("participants" , arrayContains: currentUserId).orderBy("lastMessageTime" , descending:  true).snapshots().map((snapshot)=> snapshot.docs.map((doc)=> ChatRoomModel.fromFirestore(doc)).toList());
  }
  Stream<int> getUnreadMessagesCount(
      String currentUserId ,
      String chatRoomId){
    return getchatRoomMessages(chatRoomId).where("receiverId" ,
        isEqualTo: currentUserId).where("status" , isEqualTo: messageStatus.sent.toString()).snapshots().map((snapshot) =>snapshot.docs.length);
  }

  Future<void> getMessagesAsMarked(String chatRoomId , String userId)async {
    try{
      final batch = firestore.batch();

      final unreadMessages = await getchatRoomMessages(chatRoomId).where("receiverId" , isEqualTo: userId).where("status" , isEqualTo: messageStatus.sent.toString()).get();

      for(final doc in unreadMessages.docs){
        batch.update(doc.reference,{
          "readBy" : FieldValue.arrayUnion([userId]),
          "status" : messageStatus.read.toString(),
         }
        );
        await batch.commit();
      }
    }
    catch(e){
      print("error : ${e.toString()}");
    }
  }

  Future<void> updateOnlineStatus(String userId , bool isOnline) async {
    return firestore.collection("users").doc(userId).update({
      "isOnline" : isOnline ,
      "lastSeen" : Timestamp.now(),
    });
  }

  Future<void> updateTypingStatus(String chatRoomId , String userId , bool isTyping) async {
    try{
      final doc = await _chatRooms.doc(chatRoomId).get();
      if(!doc.exists){
        print("chat room doeesnot exist");
        return;
      }
      await _chatRooms.doc(chatRoomId).update(({
        "isTyping" : isTyping,
        "typingUserId" : isTyping ? userId : "",
      }));
    }
    catch(e){
      print("error : ${e.toString()}");
    }
  }

  Stream<Map<String , dynamic>> getUserOnlineStatus(String userId){
    return firestore.collection("users").doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return{
        "isOnline" : data?["isOnline"] ?? false,
        "lastSeen" : data?["lastSeen"] ?? Timestamp.now(),
      };
    });
  }

  Stream<Map<String , dynamic>> getTypingStatus(String chatRoomId){
    return _chatRooms.doc(chatRoomId).snapshots().map((snapshot){
      if(!snapshot.exists){
        return {
          "isTyping" : false,
          "typingUserId" : "",
        };
      }
      final data = snapshot.data() as Map<String , dynamic>;
      return {
        "isTyping" : data["isTyping"] ?? false,
        "typingUserId" : data["typingUserId"] ?? "",
      };
    }
    );
  }

  Future<void> blockUser(String currentUserId , String blockedUserId) async {
      final userRef = firestore.collection("users").doc(currentUserId);
      await userRef.update({
        "blockedUsers" : FieldValue.arrayUnion([blockedUserId])
      });
  }

  Future<void> unBlockUser(String currentUserId , String blockedUserId) async {
    final userRef = firestore.collection("users").doc(currentUserId);
    await userRef.update({
      "blockedUsers" : FieldValue.arrayRemove([blockedUserId])
    });
  }

  Stream<bool> isUserBlocked(String currentUserId , String otherUserId){
    return firestore.collection("users").doc(currentUserId).snapshots().map((doc) {
      final userData = UserModel.fromFirestore(doc);
      return userData.blockedUsers.contains(otherUserId);
    });
  }

  Stream<bool> amIBlocked(String currentUserId , String otherUserId){
    return firestore.collection("users").doc(otherUserId).snapshots().map((doc) {
      final userData = UserModel.fromFirestore(doc);
      return userData.blockedUsers.contains(currentUserId);
    });
  }
  }