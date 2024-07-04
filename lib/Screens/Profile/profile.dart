import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/auth.dart';
import '../../Services/database.dart';
import '../../Utils/widget_utils.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String name = '';
  String email = '';
  String nim = '';
  String uid = '';
  String profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      uid = user.uid;
      print(uid);
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      print(doc.data());
      if (doc.exists) {
        setState(() {
          name = doc.data()?['name'] ?? '';
          email = doc.data()?['email'] ?? '';
          nim = doc.data()?['nim'] ?? '';
          profilePictureUrl = doc.data()?['profilePictureUrl'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SizedBox(height: 38.0),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 20.0),
          CircleAvatar(
            radius: 70.0,
            backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                ? NetworkImage(profilePictureUrl)
                : AssetImage('Assets/profile.jpg') as ImageProvider,
          ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            textStyleTemplate('$name'),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'NIM',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            textStyleTemplate('$nim'),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            textStyleTemplate('$email'),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 38.0, right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // In Profile screen, when navigating to EditProfile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(onProfileUpdated: () {
                              _loadUserData(); 
                            }),
                          ),
                        );
                      },
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 12.0,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 38.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService().signOut();
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        backgroundColor: Colors.white,
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
}