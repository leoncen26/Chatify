import 'package:chatify_app/models/conversation.dart';
import 'package:chatify_app/models/message.dart';
import 'package:chatify_app/pages/conversation_page.dart';
import 'package:chatify_app/providers/auth_provider.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentConversationsPage extends StatelessWidget {
  final double height, width;

  const RecentConversationsPage(this.height, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationsListView(),
      ),
    );
  }

  Widget _conversationsListView() {
    return Builder(
      builder: (BuildContext context) {
        var _auth = Provider.of<AuthProvider>(context);
        return Container(
          height: height,
          width: width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream:
                DatabaseService.instance.getUserConversations(_auth.user!.uid),
            builder: (BuildContext context,
                AsyncSnapshot<List<ConversationSnippet>> snapshot) {
              var data = snapshot.data;
              if (data != null) {
                data.removeWhere((c){
                  return c.timestamp == null;
                });
                // var filteredData = data.where((c) => c.timestamp != null).toList();
                return data.isNotEmpty
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return ConversationPage(
                                      data[index].conversationsID,
                                      data[index].id,
                                      data[index].image,
                                      data[index].name,
                                    );
                                  },
                                ),
                              );
                            },
                            title: Text(data[index].name),
                            subtitle: Text(
                              data[index].type == MessageType.Text
                                  ? data[index].lastMessage
                                  : 'Attacment: Image',
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    data[index].image,
                                  ),
                                ),
                              ),
                            ),
                            trailing: _listTileTrailing(data[index].timestamp!),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No Conversations',
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 50,
                          ),
                        ),
                      );
              } else {
                return SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
              }
            },
          ),
        );
      },
    );
  }
  // Widget _conversationsListView() {
  //   return Builder(
  //     builder: (BuildContext context) {
  //       var _auth = Provider.of<AuthProvider>(context);

  //       return Container(
  //         height: height,
  //         width: width,
  //         child: StreamBuilder<List<ConversationSnippet>>(
  //           stream:
  //               DatabaseService.instance.getUserConversations(_auth.user!.uid),
  //           builder: (BuildContext context,
  //               AsyncSnapshot<List<ConversationSnippet>> snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(
  //                 child: SpinKitWanderingCubes(
  //                   color: Colors.blue,
  //                   size: 50.0,
  //                 ),
  //               );
  //             }

  //             if (snapshot.hasData) {
  //               // Filter: hanya tampilkan jika timestamp tidak null
  //               List<ConversationSnippet> validData =
  //                   snapshot.data!.where((c) => c.timestamp != null).toList();
  //               if (validData.isEmpty) {
  //                 return const Center(
  //                   child: Text(
  //                     'No Conversations',
  //                     style: TextStyle(
  //                       color: Colors.white30,
  //                       fontSize: 20,
  //                     ),
  //                   ),
  //                 );
  //               }

  //               return ListView.builder(
  //                 itemCount: validData.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   final item = validData[index];
  //                   return ListTile(
  //                     onTap: () {
  //                       NavigationService.instance.navigateToRoute(
  //                         MaterialPageRoute(
  //                           builder: (BuildContext context) {
  //                             return ConversationPage(
  //                               item.conversationsID,
  //                               item.id,
  //                               item.image,
  //                               item.name,
  //                             );
  //                           },
  //                         ),
  //                       );
  //                     },
  //                     title: Text(item.name),
  //                     subtitle: Text(
  //                       item.type == MessageType.Text
  //                           ? item.lastMessage
  //                           : 'Attachment: Image',
  //                     ),
  //                     leading: Container(
  //                       width: 50,
  //                       height: 50,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(100),
  //                         image: DecorationImage(
  //                           fit: BoxFit.cover,
  //                           image: NetworkImage(item.image),
  //                         ),
  //                       ),
  //                     ),
  //                     trailing: _listTileTrailing(item.timestamp!),
  //                   );
  //                 },
  //               );
  //             } else if (snapshot.hasError) {
  //               return Center(
  //                 child: Text('Error: ${snapshot.error}'),
  //               );
  //             } else {
  //               return const Center(
  //                 child: Text('No Conversations'),
  //               );
  //             }
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _listTileTrailing(Timestamp _lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'last Message',
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        Text(
          timeago.format(_lastMessageTimestamp.toDate()),
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
