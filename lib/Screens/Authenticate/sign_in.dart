import 'package:flutter/material.dart';
import 'package:class_leap_flutter/Services/auth.dart';

import '../../Utils/widget_utils.dart';
import '../To Do List/Loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading ? Loading() : Scaffold(
      body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.pexels.com/photos/3793238/pexels-photo-3793238.jpeg'),
                  alignment: Alignment(0, -1.5),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                          children: <Widget>[
                            const SizedBox(height: 20.0),
                            Row(
                                children: <Widget> [Text(
                                  "Login",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 20.0, // Adjust the font size as needed
                                    fontWeight: FontWeight.bold, // Optional: for bold text
                                    color: Colors.lightBlue[700],
                                  ),
                                ),]
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                                children: <Widget> [Text(
                                  "Login to your account to get started",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14.0, // Adjust the font size as needed for the description
                                    color: Colors.grey[400], // Optional: adjust the color to fit your design
                                    // Add more styling as needed
                                  ),
                                ),]
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                              validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                              decoration: textInputDecoration('Email'),
                            ),
                            TextFormField(
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                              validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                              decoration: textInputDecoration('Password'),
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder( // Makes the button edges sharp
                                  borderRadius: BorderRadius.circular(10.0), // Set to 0 for sharp edges
                                ),
                                minimumSize: Size(double.infinity, 50), // Makes the button span nearly the parent's width and sets a fixed height
                                backgroundColor: Colors.deepOrangeAccent,
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _loading = true);
                                  dynamic result = await _authService.signInWithEmailAndPassword(email, password);
                                  if (result == null) {
                                        setState(() {
                                          _loading = false;
                                        });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to log in. Please check your credentials.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Logged in successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0, // Adjust the font size as needed
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              error,
                              style: const TextStyle(color: Colors.red, fontSize: 12.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 12.0, // Adjust the font size as needed
                                    color: Colors.grey[400], // Optional: adjust the color to fit your design
                                    // Add more styling as needed
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    widget.toggleView();
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 12.0, // Adjust the font size as needed
                                      color: Colors.lightBlue[700], // Optional: adjust the color to fit your design
                                      // Add more styling as needed
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}