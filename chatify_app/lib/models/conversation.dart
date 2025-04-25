import 'package:chatify_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSnippet {
  final String id;
  final String conversationsID;
  final String lastMessage;
  final String name;
  final String image;
  final MessageType type;
  final int unseenCount;
  final Timestamp? timestamp;

  ConversationSnippet(
      {required this.id,
      required this.conversationsID,
      required this.lastMessage,
      required this.image,
      required this.name,
      required this.type,
      required this.unseenCount,
      required this.timestamp});

  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot) {
    var data = _snapshot.data() as Map<String, dynamic>;
    var typeMessage = MessageType.Text;
    if (data['type'] != null) {
      switch (data['type']) {
        case 'text':
          break;
        case 'image':
          typeMessage = MessageType.Image;
          break;
        default:
      }
    }
    return ConversationSnippet(
      id: _snapshot.id,
      conversationsID: data['conversationID'],
      lastMessage: data['lastMessage'] != null ? data['lastMessage'] : '',
      image: data['image'],
      name: data['name'],
      unseenCount: data['unseenCount'],
      timestamp: data['timestamp'],
      type: typeMessage,
    );
  }
}

class Conversation {
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerID;

  Conversation(
      {required this.id,
      required this.members,
      required this.ownerID,
      required this.messages});

  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    List<Message> message = [];
    if (data['messages'] != null) {
      message = (data['messages'] as List).map((m) {
        var messageType =
            m['type'] == 'text' ? MessageType.Text : MessageType.Image;
        return Message(
            senderID: m['senderID'],
            content: m['message'],
            timestamp: m['timestamp'],
            type: messageType);
      }).toList();
    }
    return Conversation(
      id: snapshot.id,
      members: data['members'],
      ownerID: data['ownerID'],
      messages: message,
    );
  }
  // factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
  //   var data = snapshot.data() as Map<String, dynamic>;

  //   List<Message> message = [];
  //   if (data['messages'] != null) {
  //     message = (data['messages'] as List).map((m) {
  //       var messageType =
  //           m['type'] == 'text' ? MessageType.Text : MessageType.Image;
  //       return Message(
  //         senderID: m['senderID'],
  //         content: m['message'], // Pastikan ini sesuai dengan field Firestore
  //         timestamp: m['timestamp'],
  //         type: messageType,
  //       );
  //     }).toList();
  //   }

  //   return Conversation(
  //     id: snapshot.id,
  //     members: data['members'],
  //     ownerID: data['ownerID'],
  //     messages: message,
  //   );
  // }
}
