import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class StorageService {
  Future<String?> uploadProfilePicture(XFile imageFile) async {
    try {
      String filePath = 'profilePictures/${DateTime.now()}.png';
      firebase_storage.UploadTask uploadTask = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(filePath)
          .putFile(File(imageFile.path));

      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }
}