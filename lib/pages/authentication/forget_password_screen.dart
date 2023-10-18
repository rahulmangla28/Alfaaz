import 'package:flutter/material.dart';
import 'package:alfaaz/pages/authentication/components/forget_pwd_body.dart';


class ForgetPasswordScreen extends StatelessWidget {
  static String routeName = "/forgot_password";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: ForgetPasswordBody(),
    );
  }
}
