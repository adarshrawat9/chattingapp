import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chattingapp/data/models/chat_messaging.dart';
import 'package:chattingapp/data/services/service_locator.dart';
import 'package:chattingapp/logic/cubits/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/cubits/chat/chat_cubit.dart';

class ChatMesssageScreen extends StatefulWidget {
  final String receiverId ;
  final String receiverName ;
  const ChatMesssageScreen(
      {super.key ,
       required this.receiverId,
       required this.receiverName
      });

  @override
  State<ChatMesssageScreen> createState() => _ChatMesssageScreenState();
}

class _ChatMesssageScreenState extends State<ChatMesssageScreen> {

  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit ;
  ScrollController _scrollController = ScrollController();
  late  List<ChatMessage> _previousMessages = [];
  bool _isComposing = false;
  bool _showEmoji = false ;


  @override
  void initState(){
    _chatCubit = getit<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChange);
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onTextChange(){
    final isComposing = messageController.text.isNotEmpty;
    if(isComposing != _isComposing){
      setState(() {
        _isComposing = isComposing;
      });
    if(isComposing){
      _chatCubit.startTyping();
    }
    }
  }

  void _onScroll(){
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent-200){
    _chatCubit.loadMoreMessages();
    }
  }


  void scrollToBottom(){
    if(_scrollController.hasClients){
      _scrollController.animateTo(0, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void hasNewMessages(List<ChatMessage> messages){
    if(messages.length != _previousMessages.length){
      scrollToBottom();
      _previousMessages = messages;
    }

  }

  Future<void> _handleSendMessage() async {
    final message = messageController.text.trim();
    if (message.isNotEmpty) {
      await _chatCubit.sendMessage(
        content: message,
        receiverId: widget.receiverId,
      );
      messageController.clear();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _chatCubit.leaveChat();
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar:  AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              child: Text(widget.receiverName[0].toUpperCase()),
            ),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName),
                BlocBuilder<ChatCubit , ChatState>(
                  bloc: _chatCubit,
                  builder: (context , state){
                    if(state.isRecevierOnline == true){
                      return Container(
                        child: Text("Online" , style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),),
                      );
                    }
                    if(state.isRecevierTyping){
                      return Container(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [TyperAnimatedText("typing...")]
                          ),
                        ),
                      );
                    }
                    if(state.recevierLastSeen != null){
                      final lastSeen = state.recevierLastSeen!.toDate();
                      return Container(
                        child: Text("last seen : ${DateFormat("hh:mm a").format(lastSeen)}"
                        , style:  TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),),
                      );
                    }
                return SizedBox();
                    },),
              ],
            ),
          ],
        ),
        actions:[ BlocBuilder<ChatCubit  , ChatState>(
          bloc: _chatCubit,
            builder: (context , state) {
              if (state.isUserBlocked) {
                return IconButton(
                  onPressed: () {
                    _chatCubit.unBlockUser(widget.receiverId);
                  },
                  icon: Icon(Icons.block),
                );
              }
              return PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == "block") {
                      final bool ? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text("do you want to block this user"),
                                actions: [
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);
                                  }, child: Text("cancel")),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context , true), child: Text("confirm"),
                                  )
                                ],
                              )
                      );
                      if(confirm == true) {
                            await _chatCubit.blockUser(widget.receiverId , widget.receiverName);
                          }
                        }
                  },
                  itemBuilder: (context) =>
                  <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                        value: "block",
                        child: Text("block"),
                    )
                  ]
              );
            }
          )
        ]

      ),
      body: BlocConsumer<ChatCubit , ChatState>(
        listener: (context , state){
          hasNewMessages(state.messages);
        },
        bloc: _chatCubit,
        builder:(context ,state){
          if(state.status == ChatStatus.loading){
            return Center(child: CircularProgressIndicator());
          }
          if(state.status == ChatStatus.error){
            return Center(
              child: Text(state.errorMessage!),
            );
          }
        return  Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/chatscreen images/img.png"),
                fit: BoxFit.cover)
          ),
          child: Column(
                    children: [
                      if(state.amIBlocked)
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Text("you have been blocked by ${widget.receiverName}" , textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: _scrollController,
                          reverse: true,
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe = message.senderId == _chatCubit.currentUserId ;
                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                              );
                            }),
                      ),
                      Column(
                        children: [
                          if(!state.isUserBlocked && !state.amIBlocked)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onTap: (){
                                      if(_showEmoji){
                                        setState(() {
                                          _showEmoji = false;
                                        });
                                      }
                                    },
                                    controller: messageController,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      prefixIcon: IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey,),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3),
                                      hintText: "Message",
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                InkWell(
                                    onTap: () => _handleSendMessage(),
                                    child: Icon(Icons.send)),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
        );
              }),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timestampWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat("h:mm a").format(message.timestamp.toDate()),
          style: TextStyle(
            fontSize: 12,
            color: isMe
                ? Colors.white.withOpacity(0.7)
                : Colors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 4),
        _buildStatusIcon(
          message.status,
          isMe,
          isMe
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.5),
        ),
      ],
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            topLeft: Radius.circular(isMe ? 16 : 0),
            topRight: Radius.circular(isMe ? 0 : 16),
          ),
          color: isMe ? const Color(0xff045F5F) : Colors.grey[300],
        ),

        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [

            Text(
              message.content + '  \u00A0',
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            timestampWidget,
          ],
        ),
      ),
    );
  }
}

Widget _buildStatusIcon(messageStatus status, bool isMe, Color color) {
  if (!isMe) {
    return const SizedBox.shrink();
  }

  IconData icon;
  Color iconColor = status == messageStatus.read ? Colors.blue.shade300 : color;

  switch (status) {
    case messageStatus.sent:
      icon = Icons.done;
      break;
    case messageStatus.delivered:
      icon = Icons.done_all;
      break;
    case messageStatus.read:
      icon = Icons.done_all;
      break;
    case messageStatus.notSent:
    default:
      icon = Icons.access_time;
      break;
  }

  return Icon(
    icon,
    color: iconColor,
    size: 16,
  );
}


