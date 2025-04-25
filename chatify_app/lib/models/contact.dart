import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastSeen;
  final String name;

  Contact(
      {required this.id,
      required this.email,
      required this.image,
      required this.lastSeen,
      required this.name,});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var data = _snapshot.data() as Map<String, dynamic>;
    return Contact(
      id: _snapshot.id,
      email: data['email'],
      image: data['image'],
      lastSeen: data['lastSeen'],
      name: data['name'],
    );
  }

}
