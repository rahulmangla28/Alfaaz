import 'package:flutter/material.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/config/custome_colors.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/services/authentication/authentication.dart';

import 'sign_up_form.dart';

class SignUpBody extends StatelessWidget {
  final int isAdmin;
  final String code;
  final String orgName;
  SignUpBody(this.isAdmin, this.code, this.orgName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
          EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04), // 4%
                Text("Register Account", style: headingStyle),
                Text(
                  "Complete your details to continue ",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                  SignUpForm(isAdmin,code,orgName),
                  // FutureBuilder(
                  //     future: Authentication.initializeFirebase(context: context),
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasError) {
                  //         return Text('Error initializing Firebase');
                  //       } else if (snapshot.connectionState ==
                  //           ConnectionState.done) {
                  //         //  return GoogleSignInButton();
                  //         return SignUpForm(isAdmin);
                  //       }
                  //       return CircularProgressIndicator(
                  //         valueColor: AlwaysStoppedAnimation<Color>(
                  //           CustomColors.firebaseOrange,
                  //         ),
                  //       );
                  //     }),

                SizedBox(height: SizeConfig.screenHeight * 0.08),
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
                Text(
                  'By continuing your confirm that you agree \nwith our Term and Condition',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}