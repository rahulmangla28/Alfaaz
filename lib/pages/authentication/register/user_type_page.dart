import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alfaaz/pages/authentication/register/user_type_screen.dart';

class UserTypePage extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: UserType(),
    );
  }
}