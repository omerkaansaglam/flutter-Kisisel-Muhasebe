import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selfaccount/core/features/home_view/home_view.dart';
import 'package:selfaccount/core/features/login_view/login_view.dart';
import 'package:selfaccount/core/init/helpers/service/firebase_service.dart';

class AuthController extends StatefulWidget {
  const AuthController({Key? key}) : super(key: key);

  @override
  _AuthControllerState createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  @override
  Widget build(BuildContext context) {
    final myAuth = Provider.of<FirebaseService>(context);
    switch (myAuth.state) {
      case UserLoginState.userLogged:
        return const HomeView();
      case UserLoginState.userNotLogged:
        return const LoginView();
    }
  }
}
