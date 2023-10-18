import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:alfaaz/components/CustomSuffixIcon.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/pages/authentication/components/form_error.dart';
import 'package:alfaaz/pages/authentication/register/register_page.dart';
import 'package:alfaaz/pages/models/radio_group.dart';
import 'package:alfaaz/pages/models/register_model.dart';
import 'package:alfaaz/pages/ui/default_button.dart';
import 'package:alfaaz/routes/ui_routes.dart';


class SignUpForm extends StatefulWidget {
  final int isAdmin;
  final String code;
  final String orgName;
  SignUpForm(this.isAdmin, this.code, this.orgName);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? conform_password;
  bool remember = false;
  bool _success = false;
  late String _userEmail;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference dbRef =
  FirebaseDatabase.instance.reference().child("organisation").child("users");
  final TextEditingController emailTextEditController =
  new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmPasswordController =
  new TextEditingController();
  final List<String?> errors = [];
  bool isAdmin=false;
  String code="";
  String orgName="";
  String _errorMessage = '';
  //
  late RegisterModel userModel;
  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {

    isAdmin=widget.isAdmin==0?true:false;
    code=widget.code;
    orgName=widget.orgName;
    return Form(
      key: _formKey,
      child: Column(
        children: [
         // buildRadioGroup(),
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildConformPassFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(25)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState!.validate()) {
                _register();
                //  _formKey.currentState!.save();
                // if all are valid then go to success screen
                // Navigator.pushNamed(context, Routes.complete_profile_screen);
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildConformPassFormField() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      controller: confirmPasswordController,
      onSaved: (newValue) => conform_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        }else if (value.length >= 8) {
          removeError(error: kShortPassError);
        } else if (value.isNotEmpty && password == conform_password) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        }else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      autofocus: false,
      controller: passwordController,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: emailTextEditController,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      autofocus: true,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  void _register() async {
   // final routeArgs =
   // ModalRoute.of(context).settings.arguments as Map<String, int>;

    userModel=RegisterModel(email: emailTextEditController.text, password: passwordController.text, isAdmin: isAdmin, orgCode: code,orgName: orgName);

      Navigator.pushNamed(context, Routes.complete_profile_screen,arguments: userModel);

  }

  // void processError(final PlatformException error) {
  //   setState(() {
  //     //_errorMessage = error.message!;
  //     errors.add(error.message);
  //   });
  // }
  @override
  void dispose(){
    super.dispose();
  }

  // buildRadioGroup() {
  //   return Expanded(
  //       child: Container(
  //         height: 350.0,
  //         child: Column(
  //           children:
  //           radioList.map((data) => RadioListTile(
  //             title: Text("${data.value}"),
  //             groupValue: 1,
  //             value: data.id,
  //             onChanged: (val) {
  //               setState(() {
  //                 //radioItem = data.value ;
  //                 _radioVal = data.id;
  //               });
  //             },
  //           )).toList(),
  //         ),
  //       ));
  // }
}
