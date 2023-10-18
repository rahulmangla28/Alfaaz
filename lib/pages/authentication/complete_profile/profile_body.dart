import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/pages/authentication/complete_profile/complete_profile_form.dart';
import 'package:alfaaz/pages/models/register_model.dart';

class ProfileBody extends StatelessWidget{
  final RegisterModel newUser;

   ProfileBody( this.newUser);

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
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                Text("Complete Profile", style: headingStyle),
                Text(
                  "Complete your details to continue  ",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.06),
                CompleteProfileForm(newUser),
                SizedBox(height: getProportionateScreenHeight(30)),
                Text(
                  "By continuing your confirm that you agree \nwith our Term and Condition",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}