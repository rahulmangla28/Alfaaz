import 'package:flutter/material.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/pages/authentication/register/sign_up_body.dart';

class RegisterPageArgs{
  final bool isAdmin;

  RegisterPageArgs(this.isAdmin);



}
class RegisterPage extends StatelessWidget {
  final int isAdmin;
  final String orgCode;
  final String orgName;
  const RegisterPage({Key? key, required this.isAdmin,  required this.orgCode, required this.orgName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final routeArgs =
    // ModalRoute.of(context).settings.arguments as Map<String, int>;
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: SignUpBody(isAdmin,orgCode,orgName),
    );
  }
}