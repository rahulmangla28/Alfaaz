import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:alfaaz/config/custom_colors.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/services/authentication/authentication.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';


import 'no_account_text.dart';
import 'sign_form.dart';

class SignInBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      body: SizedBox(
        width: double.infinity,
        child: Padding(

          padding:
          EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Sign in with your email and password  \nto continue ",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                SignForm(),
              //  SizedBox(height: SizeConfig.screenHeight * 0.08),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     SocalCard(
                //       icon: "assets/icons/google-icon.svg",
                //       press: () {},
                //     ),
                //     SocalCard(
                //       icon: "assets/icons/facebook-2.svg",
                //       press: () {},
                //     ),
                //     SocalCard(
                //       icon: "assets/icons/twitter.svg",
                //       press: () {},
                //     ),
                //   ],
                // ),
                SizedBox(height: getProportionateScreenHeight(20)),

                NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}