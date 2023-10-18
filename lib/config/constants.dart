import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alfaaz/config/size_config.dart';

const appAccentColor = Color(0xFF639CFF);
const appLightColor = Color(0xFF9EB7E8);
const appPurpleColor = Color(0xFF6C63FF);
var appAccentIconColor = Color(0xFF6397FF).withOpacity(0.8);
const appBlueColor= Color(0xFF2E7CF8);
const white=Color(0xFFFFFFFF);
const appLightBlueColor= Color(0xFF9CC0F8);

const kPrimaryColor = Color(0xFF2E7CF8);
const kPrimaryLightColor = Color(0xFFDFE7FF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF3E95FF), Color(0xFF4372FF)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

final RegExp emailValidatorRegExp =
RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";


final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final otpInputDecoration = InputDecoration(
  contentPadding:
  EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}