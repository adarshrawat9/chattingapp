import 'package:cloud_firestore/cloud_firestore.dart';


class ChatRoomModel{
  final String id;
  final List<String> participants ;
  final Map<String , String>? participantsName;
  final String? lastMessage ;
  final String? lastMessageSenderId ;
  final bool isTyping ;
  final Timestamp? lastMessageTime;
  final String? typingUserId ;
  final Map<String , Timestamp>? lastReadTime;
  final bool isCallActive;
  final String? encryptionKey;

  ChatRoomModel(
   {required this.id,
     required this.participants,
     Map<String ,String>? participantsName,
     this.lastMessage,
     this.lastMessageSenderId,
     this.isTyping = false,
     this.lastMessageTime,
     required this.typingUserId,
     Map<String ,Timestamp>? lastReadTime,
     this.isCallActive = false,
     required this.encryptionKey,
   }
      ): lastReadTime = lastReadTime ?? {},
         participantsName =participantsName ?? {};

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String , dynamic>;
    return ChatRoomModel(
        id: doc.id,
        participants: List<String>.from(data["participants"]),
        typingUserId: data["typingUserId"],
        participantsName: Map<String ,String>.from(data["participantsName"] ?? {},),
        lastMessage: data["lastMessage"],
        lastMessageSenderId: data["lastMessageSenderId"],
        isTyping: data["isTyping"] ?? false,
        lastMessageTime: data["lastMessageTime"],
        lastReadTime: Map<String ,Timestamp>.from(data["lastReadTime"] ?? {}),
        isCallActive: data["isCallActive"] ?? false,
        encryptionKey: data["encryptionKey"] ?? "",
    );
  }


  Map< String , dynamic> toMap(){
    return {
      "participants" : participants,
      "participantsName" : participantsName,
      "lastMessage" : lastMessage ,
      "lastMessageSenderId" : lastMessageSenderId,
      "lastMessageTime" : lastMessageTime,
      "isTyping" : isTyping,
      "typingUserId"  : typingUserId,
      "lastReadTime" : lastReadTime,
      "isCallActive" : isCallActive,
      "encryptionKey" : encryptionKey,
    };
  }

 }