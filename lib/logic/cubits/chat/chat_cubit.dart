import 'dart:async';
import 'dart:ffi';

import 'package:chattingapp/data/repositories/chat_repository.dart';
import 'package:chattingapp/logic/cubits/chat/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState>{
  final ChatRepository _chatRepository ;
  final String currentUserId ;
  StreamSubscription ? _chatMessageSubsricption ;
  bool inChat = false ;
  StreamSubscription ? _typingSubscription ;
  StreamSubscription ? _onlineSubscription ;
  StreamSubscription ? _blockSubscription ;
  StreamSubscription ? _amIBlockStatusSubscription ;
  Timer? typingTimer ;


  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  }) : _chatRepository = chatRepository , super(ChatState());

  void enterChat(String receiverId)async{
    inChat = true;
    emit(state.copyWith(status: ChatStatus.loading));
    try{
      final chatRoom =await _chatRepository.getOrCreateChatRoom(currentUserId, receiverId);
      emit(state.copyWith(chatRoomId:chatRoom.id , receiverId: receiverId , status: ChatStatus.success));
      _subscribeToMessages(chatRoom.id);
      _subscribeToOnlineStatus(receiverId);
      _subscribeToTypingStatus(chatRoom.id);
      _subscribeToBlockStatus(receiverId);
      await _chatRepository.updateOnlineStatus(currentUserId, true);
    }
    catch(e){
      emit(state.copyWith(status: ChatStatus.error , errorMessage: "failed to create chat room $e"));
    }
  }

  Future<void> sendMessage({
    required String content,
    required String receiverId,
})async {
    if(state.chatRoomId == null ){
      return;
    }
    try{
      await _chatRepository.sendMessage(
        chatRoomId: state.chatRoomId!,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
      );
    }
    catch(e){
      emit(state.copyWith(status: ChatStatus.error , errorMessage: "failed to send message $e"));
    }
  }

  void startTyping(){
    if(state.chatRoomId == null) return;
    typingTimer?.cancel();
    updateTypingStatus(true);
    typingTimer = Timer(Duration(seconds: 3 ) , (){
      updateTypingStatus(false);
    });
  }

  Future<void> updateTypingStatus(bool isTyping) async {
    if(state.chatRoomId == null) return;

    try{
      await _chatRepository.updateTypingStatus(state.chatRoomId!, currentUserId, isTyping);
    }
    catch(e){
      print("error updating typing status ${e.toString()}");
      
    }
  }
  void _subscribeToMessages (String chatRoomId) async {
    _chatMessageSubsricption?.cancel();
    _chatMessageSubsricption = await _chatRepository.getMessage(chatRoomId).listen((messages) {
      if(inChat){
        _markMessagesAsRead(chatRoomId);
      }
      emit(state.copyWith(
        messages:  messages,
        errorMessage: null,
        status: ChatStatus.success
      ));
    },
        onError: (error) {
          print("  Error while listening to messages: $error");
      emit(state.copyWith(
        errorMessage: "failed to load messages",
        status: ChatStatus.error
      ));
    }
    );
  }

  Future<void> _markMessagesAsRead(String chatRoomId) async {
    try{
      await _chatRepository.getMessagesAsMarked(chatRoomId,currentUserId);
    }
    catch(e){
      print("error ${e.toString()}");
    }
  }

  void _subscribeToOnlineStatus(String userId){
    _onlineSubscription?.cancel();
    _onlineSubscription = _chatRepository.getUserOnlineStatus(userId).listen((status) {
      final isOnline = status["isOnline"] as bool;
      final lastSeen = status["lastSeen"] as Timestamp?;
      emit(state.copyWith(
        isRecevierOnline: isOnline,
        recevierLastSeen: lastSeen,
      ));
    },
    onError:  (error){
      print("error : ${error.toString()}");
    }
    );
  }

  void _subscribeToTypingStatus(String chatRoomId){
    _typingSubscription?.cancel();
    _typingSubscription = _chatRepository.getTypingStatus(chatRoomId).listen((status) {
      final isTyping = status["isTyping"] as bool;
      final typingUserId = status["typingUserId"] as String?;
      emit(state.copyWith(
        isRecevierTyping: isTyping && typingUserId != currentUserId,
        receiverId: typingUserId,
      ));
    },
        onError:  (error){
          print("error : ${error.toString()}");
        }
    );
  }

  Future<void> loadMoreMessages() async {
    if (state.status != ChatStatus.success ||
        state.messages.isEmpty ||
        !state.hasMoreMessaages ) return;

    try {
      emit(state.copyWith(isLoadingMoreMessages: true));

      final lastMessage = state.messages.last;
      final lastDoc = await _chatRepository
          .getchatRoomMessages(state.chatRoomId!).doc(lastMessage.id).get();

      final moreMessages = await _chatRepository.loadMoreMessages(chatRoomId: state.chatRoomId!, lastDocument: lastDoc);

      if (moreMessages.isEmpty) {
        emit(state.copyWith(hasMoreMessaages: false, isLoadingMoreMessages: false));
        return;
      }

      emit(
        state.copyWith(
            messages: [...state.messages, ...moreMessages],
            hasMoreMessaages: moreMessages.length >= 20,
            isLoadingMoreMessages: false),
      );
    } catch (e) {
      emit(state.copyWith(
          errorMessage: "Failed to laod more messages", isLoadingMoreMessages: false));
    }
  }
  Future<void> leaveChat() async {
    inChat = false ;
  }

  Future<void> blockUser(String userId ,String userName)async {
    try{
      await _chatRepository.blockUser(currentUserId, userId);
    }
    catch(e){
      emit(state.copyWith(errorMessage: "failed to block user ${e.toString()}"));
    }
  }

  Future<void> unBlockUser(String userId)async {
    try{
      await _chatRepository.unBlockUser(currentUserId, userId);
    }
    catch(e){
      emit(state.copyWith(errorMessage: "failed to unblock user ${e.toString()}"));
    }
  }

  void _subscribeToBlockStatus(String otherUserId) {
    _blockSubscription?.cancel();
    _blockSubscription = _chatRepository
        .isUserBlocked(currentUserId, otherUserId)
        .listen((isBlocked) {
      emit(
        state.copyWith(isUserBlocked: isBlocked),
      );

      _amIBlockStatusSubscription?.cancel();
      _blockSubscription = _chatRepository
          .amIBlocked(currentUserId, otherUserId)
          .listen((isBlocked) {
        emit(
          state.copyWith(amIBlocked: isBlocked),
        );
      });
    }, onError: (error) {
      print("error getting online status");
    });
  }


}