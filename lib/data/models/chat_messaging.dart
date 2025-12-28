
import 'package:chattingapp/core/utils/encryption_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum messageType{text , video , image , file , audio}

enum messageStatus{sent , delivered , read , notSent}

class ChatMessage{

  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final messageType type;
  final messageStatus status;
  final Timestamp timestamp;
  final List<String> readBy;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = messageType.text,
    this.status = messageStatus.notSent ,
    required this.timestamp,
    required this.readBy,
  });


  static Future<ChatMessage> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String , dynamic>;
    final decryptContent = await EncryptionHelper.decryptText(data["content"] ?? "" , data["chatRoomId"] ?? "");
    return ChatMessage(
        id: doc.id,
        chatRoomId: data["chatRoomId"] ?? "" ,
        senderId: data["senderId"] ?? "",
        receiverId: data["receiverId"] ?? "",
        content: decryptContent,
        type: messageType.values.firstWhere((e)=> e.name == data["type"] , orElse: ()=> messageType.text),
        status: messageStatus.values.firstWhere((e)=> e.name == data["status"] , orElse: ()=> messageStatus.sent),
        timestamp: data["timestamp"] ?? Timestamp.now(),
        readBy: List<String>.from(data["readBy"] ?? [],),
    );
  }

  Future<Map<String , dynamic>> toMap() async {
    return{
      "chatRoomId" : chatRoomId,
      "senderId" : senderId,
      "receiverId" : receiverId,
      "content" : await EncryptionHelper.encryptText(content,chatRoomId),
      "type" : type.name,
      "status" : status.name,
      "timestamp" : timestamp,
      "readBy" : readBy,
    };
  }

  ChatMessage copyWith({
    String ?id,
    String ?chatRoomId,
    String ?senderId,
    String ?receiverId,
    String ?content,
    messageType ?type,
    messageStatus ?status,
    Timestamp ?timestamp,
    List<String> ?readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
    );
  }
}