import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:class_leap_flutter/Services/storage.dart';
import 'package:provider/provider.dart';
import '../../Models/user.dart';
import '../../Services/database.dart';
import '../../Utils/widget_utils.dart';

import '../To Do List/Loading.dart';

class EditProfile extends StatefulWidget {
  final Function onProfileUpdated;
    const EditProfile({Key? key, required this.onProfileUpdated}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  String name='';
  String imageUrl='';
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  late String uid;
  final TextEditingController _nameController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Now you can use context because initState is called after the object is fully initialized
    uid = Provider.of<User?>(context, listen: false)?.uid ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      uid = user.uid;
      print(uid);
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
           _nameController.text = doc.data()?['name'] ?? '';
           name = doc.data()?['name'] ?? '';
          imageUrl = doc.data()?['profilePictureUrl'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isUploading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text(
          'Class Leap',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 20.0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20.0),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20.0),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  InkWell(
                    // Assuming _isUploading is already defined and initialized to false
                    onTap: () async {
                      print('Selecting image');
                      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      print('Image selected: $image');
                      if (image != null) {
                        setState(() {
                          _isUploading = true; // Start uploading
                        });
                        print('Uploading image');
                        try {
                          imageUrl = (await _storageService.uploadProfilePicture(image))!;
                          print('Image URL: $imageUrl');
                        } finally {
                          setState(() {
                            _isUploading = false; // Stop uploading
                          });
                        }
                      } else {
                        print('No image selected');
                      }
                    },
                    child: Stack(
                      children: <Widget> [
                        Opacity(opacity: 0.6,
                        child: Icon(Icons.edit, size: 150.0, color: Colors.grey[100])),
                        Ink.image(
                        image: imageUrl != null && imageUrl!.isNotEmpty
                            ? NetworkImage(imageUrl!)
                            : AssetImage('Assets/profile.jpg') as ImageProvider,
                        width: 150, // Set your desired width
                        height: 150, // Set your desired height
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    margin: EdgeInsets.only(left: 36.0, right: 36.0), // Add left and right margins
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[400] ?? Colors.grey, // Set border color
                        width: 1.5, // Set border width
                      ),
                      borderRadius: BorderRadius.circular(5.0), // Set border radius
                    ),
                    child: TextFormField(
                      onChanged: (val) {
                        setState(() => name = val);
                      },
                      decoration: textInputDecoration('Nama'),
                       controller: _nameController, 
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // This will add equal spacing around the buttons
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 38.0, right: 38.0), // Adjust the padding as needed
                    child: ElevatedButton(
                      onPressed: () async {
                        if (imageUrl != null) {
                          print('Updating profile');
                          if(name == ''){
                            name = _nameController.text;
                          }
                          await DatabaseService.getInstance(uid: uid).updateUserProfile(name, imageUrl);
                          print('Profile updated successfully!');
                          widget.onProfileUpdated();
                          Navigator.pop(context); 
                        }
                      },
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        backgroundColor: Colors.deepOrangeAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _nameController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}
