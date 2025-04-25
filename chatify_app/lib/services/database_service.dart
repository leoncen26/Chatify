import 'package:chatify_app/models/contact.dart';
import 'package:chatify_app/models/conversation.dart';
import 'package:chatify_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();

  FirebaseFirestore? _db;
  String _collectionUser = 'Users';
  String _collectionConversations = 'Conversations';

  DatabaseService() {
    _db = FirebaseFirestore.instance;
  }

  Future<void> createUser(
      String uid, String name, String email, String imageUrl) async {
    try {
      // print("Creating user in Firestore...");
      // print("Data: $uid | $name | $email | $imageUrl");
      return await _db!.collection(_collectionUser).doc(uid).set({
        'name': name,
        'email': email,
        'image': imageUrl,
        'lastSeen': DateTime.now().toUtc(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeen(String _userID) {
    var ref = _db!.collection(_collectionUser).doc(_userID);
    return ref.update({'lastSeen': Timestamp.now()});
  }

  Future<void> sendMessage(String conversationID, Message message) {
    var ref = _db!.collection(_collectionConversations).doc(conversationID);
    var messageType = '';
    switch (message.type) {
      case MessageType.Text:
        messageType = 'text';
        break;
      case MessageType.Image:
        messageType = 'image';
        break;
      default:
    }
    return ref.update({
      'messages': FieldValue.arrayUnion(
        [
          {
            'message': message.content,
            'senderID': message.senderID,
            'timestamp': message.timestamp,
            'type': messageType,
          },
        ],
      )
    });
  }

  Future<void> createOrGetConversation(String currentID, String recepientID,
      Future<void> onSuccess(String conversationID)) async {
    var ref = _db!.collection(_collectionConversations);
    var userConversationRef = _db!
        .collection(_collectionUser)
        .doc(currentID)
        .collection(_collectionConversations);
    try {
      var conversation = await userConversationRef.doc(recepientID).get();
      var data = conversation.data();
      if (data != null) {
        return onSuccess(data['conversationID']);
      } else {
        var conversationRef = ref.doc();
        await conversationRef.set(
          {
            'members': [currentID, recepientID],
            'ownerID': currentID,
            'message': [],
          },
        );
        return onSuccess(conversationRef.id);
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<Contact> getUserData(String _userID) {
    var ref = _db!.collection(_collectionUser).doc(_userID);
    return ref.snapshots().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String _userID) {
    var ref = _db!
        .collection(_collectionUser)
        .doc(_userID)
        .collection(_collectionConversations);
    return ref.snapshots().map((_snapshot) {
      return _snapshot.docs.map((doc) {
        return ConversationSnippet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUserInDB(String _searchName) {
    var ref = _db!
        .collection(_collectionUser)
        .where('name', isGreaterThanOrEqualTo: _searchName)
        .where('name', isLessThan: _searchName + 'z');
    return ref.get().asStream().map((_snapshot) {
      return _snapshot.docs.map((doc) {
        return Contact.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversations(String conversationID) {
    var ref = _db!.collection(_collectionConversations).doc(conversationID);
    return ref.snapshots().map((snapshot) {
      return Conversation.fromFirestore(snapshot);
    });
  }
}
