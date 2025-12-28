
import 'package:chattingapp/config/theme/app_theme.dart';
import 'package:chattingapp/data/repositories/auth_repository.dart';
import 'package:chattingapp/data/repositories/chat_repository.dart';
import 'package:chattingapp/data/repositories/contact_repository.dart';
import 'package:chattingapp/presentation/chat/chat_messsage_screen.dart';
import 'package:chattingapp/presentation/widgets/chat_list_tile.dart';
import 'package:chattingapp/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:chattingapp/logic/cubits/auth/auth_cubit.dart';

import '../../data/services/service_locator.dart';
import '../screens/auth/Login_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository ;
  late final ChatRepository _chatRepository;
  late final String _currentUserId ;
  @override
  void initState() {
    _contactRepository = getit<ContactRepository>();
    _chatRepository = getit<ChatRepository>();
    _currentUserId = getit<AuthRepository>().currentUser?.uid ?? "";
    super.initState();
  }

  void _showContactList(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text("Contacts",
                 style: TextStyle(
                   fontWeight: FontWeight.w700,
                   fontSize: 28,
                   color: Colors.black54,
                 ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<List<Map<String , dynamic>>>(
                            future: _contactRepository.getRegisteredContacts(),
                            builder: (context , snapshot){
                              if(snapshot.hasError){
                                return Center(
                                  child: Text("Error : ${snapshot.error}"),
                                );
                              }
                              if(!snapshot.hasData){
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final contacts = snapshot.data!;
                              if(contacts.isEmpty){
                                  return Center(
                                    child: Text("No contacts found"),
                                  );
                              }
                              return ListView.builder(
                                itemCount: contacts.length,
                                itemBuilder: (context, index) {
                                final contact = contacts[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    child: Text(contact["name"][0].toUpperCase()),
                                  ),
                                  title: Text(contact["name"].toString().toUpperCase(),
                                  ),
                                  onTap: (){
                                    getit<AppRouter>().push(ChatMesssageScreen(
                                      receiverId : contact["id"],
                                      receiverName : contact["name"],
                                    ));
                                  },
                                );
                               },
                              );
                            },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("chats"),
        actions: [
         InkWell(
           onTap: ()async {
             await getit<AuthCubit>().signOut();
             getit<AppRouter>().pushAndRemoveUntil(const LoginScreen());
             },
             child: Icon(Icons.logout)),
        ],
      ),
      body: StreamBuilder(stream: _chatRepository.getChatRooms(_currentUserId),
          builder: (context , snapshot) {
        if(snapshot.hasError){
          return Center(
            child: Text("error : ${snapshot.error}"),
          );
        }
        if(!snapshot.hasData){
          return Center(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final chats = snapshot.data!;
        if(chats.isEmpty){
          return Center(
            child: Text("your recent chats will appear here"),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
            itemBuilder: (context , index){
          final chat = chats[index];
          return ChatListTile(chatRoom: chat,
              currentUserId: _currentUserId,
              onTap:(){
            final otherUserId = chat.participants.firstWhere((id)=> id != _currentUserId);
            final otherUserName = chat.participantsName![otherUserId] ?? "Unknown";
            getit<AppRouter>().push(ChatMesssageScreen(
                receiverId: otherUserId ,
                receiverName: otherUserName,
             ) ,
            );
              } );
        });
          }
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showContactList(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 3,
        child: Icon(Icons.chat),
      ),
    );
  }
}
