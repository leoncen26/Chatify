import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage? _storage;
  Reference? _baseRef;

  String _profileImage = 'profile_image';
  String _messages = 'messages';
  String _images = 'images';

  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage!.ref();
  }

  Future<String> uploadProfileImage(String uid, File image) async {
    try {
      final ref = _baseRef!.child(_profileImage).child(uid);

      // Mulai proses upload
      UploadTask uploadTask = ref.putFile(image);

      // Tunggu hingga upload selesai
      TaskSnapshot snapshot = await uploadTask;

      // Ambil URL dari gambar yang telah diupload
      String imageUrl = await snapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print("Upload failed: $e");
      rethrow;
    }
  }

  Future<TaskSnapshot> uploadMediaMessage(String uid, File file) async{
    var timestamp = DateTime.now();
    var fileName = basename(file.path);
    fileName += "_${timestamp.toString()}";
    try {
      final ref = _baseRef!.child(_messages).child(uid).child(_images).child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      return await uploadTask;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
