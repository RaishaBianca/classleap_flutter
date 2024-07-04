import 'package:flutter/material.dart';
import '../../Services/auth.dart';
import '../../Utils/widget_utils.dart';
import '../To Do List/Loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';
  String name = '';
  String nim = '';
  bool _loading = false;

  final AuthService _authService = AuthService();
  

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
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.78,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20.0),
                           Row(
                             children: <Widget> [Text(
                                "Register",
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
                                "Create your account to get started",
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
                              setState(() => name = val);
                            },
                            validator: (val) => val!.isEmpty ? 'Enter a name' : null,
                            decoration: textInputDecoration('Name'),
                          ),
                          TextFormField(
                            onChanged: (val) {
                              setState(() => nim = val);
                            },
                            validator: (val) => val!.isEmpty ? 'Enter a NIM' : null,
                            decoration: textInputDecoration('NIM (must start with 21 or 22)'),
                          ),
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
                                print(name);
                                print(email);
                                print(password);
                                print(nim);
                                dynamic result;
                                try {
                                  result = await _authService.registerWithEmailAndPassword(email, password, name, nim);
                                }
                                catch (e) {
                                  print(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: NIM already exists.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                }
                                print('result : $result');
                                if (result == null || result == false) {
                                      setState(() {
                                          _loading = false;
                                        });
                                      error = 'Failed to register. Please check your credentials and try again.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to register. Please check your credentials.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Registered successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              'Register',
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
                                "Already have an account? ",
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
                                  'Sign in',
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
        ),
      ]),
    );
  }
}