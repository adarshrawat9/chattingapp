

import 'package:chattingapp/data/models/chat_room_model.dart';
import 'package:chattingapp/data/repositories/chat_repository.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import '../../data/services/service_locator.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chatRoom;
  final String currentUserId;
  final VoidCallback onTap;


  const ChatListTile({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.onTap,
  });
  String getOtherUserName(){
    final otherUserId = chatRoom.participants.firstWhere((id) => id != currentUserId);
    return chatRoom.participantsName![otherUserId] ?? "Unknown" ;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(getOtherUserName()[0].toUpperCase()),
      ),
      title: Text(getOtherUserName()),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      subtitle: Row(
        children: [
          Expanded(child: Text(chatRoom.lastMessage ?? "" , maxLines: 1 , overflow: TextOverflow.ellipsis,)),
        ],
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
     trailing: StreamBuilder(stream: getit<ChatRepository>().getUnreadMessagesCount(currentUserId, chatRoom.id),
         builder: (context , snapshot){
       if(!snapshot.hasData || snapshot.data == 0 ){
         return SizedBox.shrink();
       }
       return Container(
         padding: EdgeInsets.all(0.8),
         decoration: BoxDecoration(
           color: Theme.of(context).colorScheme.secondary,
           shape: BoxShape.circle,
         ),
         child: Text(
           snapshot.data.toString(),
           style: TextStyle(
             color: Colors.white
         ),
         )
       );
         })
    );
  }
}
