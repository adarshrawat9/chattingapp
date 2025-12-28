
import 'package:chattingapp/data/repositories/chat_repository.dart';
import 'package:flutter/cupertino.dart';

class AppLifeCycleObserver extends WidgetsBindingObserver{

  final String userId;
  final ChatRepository chatRepository;

  AppLifeCycleObserver({
    required this.userId,
    required this.chatRepository,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        chatRepository.updateOnlineStatus(userId , false);
        break;

      case AppLifecycleState.resumed:
        chatRepository.updateOnlineStatus(userId , true);
        break;

      default:
    }
  }
}