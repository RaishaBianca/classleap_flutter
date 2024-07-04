import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:provider/provider.dart';

import 'Models/user.dart';
import 'Screens/Wrapper.dart';
import 'Services/auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        home: AnimatedSplashScreen(
          splash: 'Assets/logo.png',
          nextScreen: Wrapper(),
          splashTransition: SplashTransition.fadeTransition,
          duration: 1500,
          splashIconSize: 450.0,
          pageTransitionType: PageTransitionType.fade,
        ),
      ),
    );
  }
}