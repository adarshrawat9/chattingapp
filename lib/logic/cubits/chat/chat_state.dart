
import 'package:chattingapp/data/models/chat_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus{initial , loading , success , error}

class ChatState extends Equatable{
  final ChatStatus status ;
  final String? errorMessage;
  final String? receiverId ;
  final String? chatRoomId ;
  final List<ChatMessage> messages;
  final bool isRecevierTyping;
  final bool isRecevierOnline;
  final Timestamp? recevierLastSeen ;
  final bool hasMoreMessaages;
  final bool? isLoadingMoreMessages;
  final bool isUserBlocked;
  final bool amIBlocked;

  ChatState({
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.receiverId,
    this.chatRoomId,
    this.messages = const [],
    this.isRecevierOnline = false,
    this.isRecevierTyping = false,
    this.recevierLastSeen,
    this.hasMoreMessaages = true,
    this.isLoadingMoreMessages = false,
    this.isUserBlocked = false,
    this.amIBlocked = false,
  });

  ChatState copyWith({
    ChatStatus ? status,
    String ? errorMessage,
    String ? receiverId,
    String ? chatRoomId,
    List<ChatMessage> ? messages,
    bool ? isRecevierOnline,
    bool ? isRecevierTyping,
    Timestamp ? recevierLastSeen,
    bool ? hasMoreMessaages,
    bool ? isLoadingMoreMessages,
    bool ? isUserBlocked,
    bool ? amIBlocked,

}){
    return ChatState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        receiverId: receiverId ?? this.receiverId,
        chatRoomId: chatRoomId ?? this.chatRoomId,
        messages: messages ?? this.messages,
        isRecevierOnline:  isRecevierOnline ?? this.isRecevierOnline,
        isRecevierTyping: isRecevierTyping ?? this.isRecevierTyping,
        recevierLastSeen: recevierLastSeen ?? this.recevierLastSeen,
        hasMoreMessaages: hasMoreMessaages ?? this.hasMoreMessaages ,
        isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
        isUserBlocked: isUserBlocked ?? this.isUserBlocked,
        amIBlocked: amIBlocked ?? this.amIBlocked,
    );

  }

  @override
  List<Object?> get props =>[status , errorMessage , receiverId , chatRoomId , messages , isRecevierOnline , isRecevierTyping , recevierLastSeen , hasMoreMessaages , isLoadingMoreMessages , isUserBlocked , amIBlocked];
}