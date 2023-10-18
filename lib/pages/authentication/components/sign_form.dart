import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:alfaaz/components/CustomSuffixIcon.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/pages/authentication/components/form_error.dart';
import 'package:alfaaz/pages/ui/default_button.dart';
import 'package:alfaaz/pages/ui/keyboard.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:alfaaz/services/authentication/authentication.dart';


import '../user_info_page.dart';


class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? code;
  bool? remember = false;
  late User user;
  final List<String?> errors = [];
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController codeController = new TextEditingController();
  int f=0;
  String _errorMessage = '';

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

  void onChange() {
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    emailController.addListener(onChange);
    passwordController.addListener(onChange);

    return Form(

      key: _formKey,
      child: Column(

        children: [

          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30),),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildCodeFormField(),
          Row(
            children: [

              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(
                        context, Routes.forget_password),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState!.validate()) {
                //  _formKey.currentState!.save();
                String s=codeController.text;
                print('code:$s');
                signIn(emailController.text, passwordController.text)
                    .then((uid) =>
                {
                  if (uid != null) {
                    print(uid),
                    KeyboardUtil.hideKeyboard(context),
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            UserInfoPage(
                              user: FirebaseAuth.instance.currentUser as User,
                              orgCode: s,
                            ),
                      ),
                    )
                  }
                  else
                    {
                      FormError(errors: errors)
                    }
                });
              }
              //KeyboardUtil.hideKeyboard(context);

              //      Navigator.pushNamed(context, Routes.home)});


              //   .catchError((error) => {processError(error)}) as UserCredential;
              // if all are valid then go to success screen


              // if (userCredential.user != null) {
              //   Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(
              //       builder: (context) => UserInfoPage(
              //         user: userCredential.user as User,
              //       ),
              //     ),
              //   );
              // }else{
              //   print(userCredential.user);
              //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //     content: Text("njwndj"),
              //   ));
              // }
              //  Navigator.pushNamed(context, Routes.home);

            },)
          ,]
        ,
      )
      ,
    );
  }
  TextFormField buildCodeFormField() {
    return TextFormField(

      controller: codeController,
      onSaved: (newValue) => code = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
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
      // textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: "Organisation Code",
        hintText: "Enter your Organisation Code",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      controller: passwordController,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
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
      // textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
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
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
      //   textInputAction: TextInputAction.next,
      // onEditingComplete: () => node.nextFocus(),
    );
  }


  Future<UserCredential?> signIn(final String email,
      final String password) async {
    UserCredential? userCredential;
    // await Firebase.initializeApp();
    Authentication.initializeFirebase(context: context);
    //final UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;


      // return userCredential;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errors.add("Unable to find user. Please register.");
      } else if (e.code == 'wrong-password') {
        errors.add("Incorrect Password");
      }
      else {
        errors.add("There was an error logging in. Please try again later.");
      }
    }
    return null;
  }

  void processError(final PlatformException error) {
    if (error.code == "ERROR_USER_NOT_FOUND") {
      setState(() {
        errors.add("Unable to find user. Please register.");
      });
    } else if (error.code == "ERROR_WRONG_PASSWORD") {
      setState(() {
        // _errorMessage = "Incorrect password.";
        errors.add("Incorrect Password");
      });
    } else {
      setState(() {
        // _errorMessage =
        errors.add("There was an error logging in. Please try again later.");
      });
    }
  }

  @override
  void dispose() {
    // passwordController.removeListener(onChange);
    // emailController.removeListener(onChange);
    super.dispose();
  }



}