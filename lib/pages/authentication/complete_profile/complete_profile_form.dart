import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:alfaaz/components/CustomSuffixIcon.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/pages/authentication/components/form_error.dart';
import 'package:alfaaz/pages/authentication/register/register_page.dart';
import 'package:alfaaz/pages/authentication/user_info_page.dart';
import 'package:alfaaz/pages/models/register_model.dart';
import 'package:alfaaz/pages/ui/default_button.dart';
import 'package:alfaaz/pages/ui/keyboard.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';


class CompleteProfileForm extends StatefulWidget {
  final RegisterModel currUser;

   CompleteProfileForm(this.currUser) ;
  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState(currUser);
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? address;
  final TextEditingController fNameController = new TextEditingController();
  final TextEditingController sNameController = new TextEditingController();
  final TextEditingController mobilePhoneController =
      new TextEditingController();
  final TextEditingController addressController = new TextEditingController();

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("organisation");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  RegisterModel currUser;
  bool isAdmin=false;

  _CompleteProfileFormState(this.currUser);
  //final  UUId uid;
  @override
  void initState() {
    super.initState();
   // getUser();
  }

  // void getUser(){
  //   //currUser = _firebaseAuth.currentUser!;
  //   currentUser=
  // //  uid = currUser.uid;
  // }
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
    //getUser();
    // final routeArgs =
    // ModalRoute.of(context).settings.arguments as Map<String, int>;
    // if(arguments['_radioVal']=='isAdmin')  isAdmin=true;
    currUser=widget.currUser;
    return WillPopScope(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildFirstNameFormField(),
              SizedBox(height: getProportionateScreenHeight(30)),
              buildLastNameFormField(),
              SizedBox(height: getProportionateScreenHeight(30)),
              buildPhoneNumberFormField(),
              SizedBox(height: getProportionateScreenHeight(30)),
              buildAddressFormField(),
              FormError(errors: errors),
              SizedBox(height: getProportionateScreenHeight(40)),
              DefaultButton(
                text: "continue",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    completeProfile();

                  }
                },
              ),
            ],
          ),
        ),
        onWillPop: onWillPop);
  }

  TextFormField buildAddressFormField() {
    return TextFormField(
      controller: addressController,
      onSaved: (newValue) => address = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kAddressNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kAddressNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Address",
        hintText: "Enter your phone address",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon:
            CustomSuffixIcon(svgIcon: "assets/icons/Location point.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      controller: mobilePhoneController,
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNumber = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter your phone number",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildLastNameFormField() {
    return TextFormField(
      controller: sNameController,
      onSaved: (newValue) => lastName = newValue,
      decoration: InputDecoration(
        labelText: "Last Name",
        hintText: "Enter your last name",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      controller: fNameController,
      onSaved: (newValue) => firstName = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNamelNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "First Name",
        hintText: "Enter your first name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  Future<bool> onWillPop() async {
    //deleteUser();
    Navigator.pop(context);
    return true;
  }


  Future<void> deleteUser() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
      }
    }
  }

  Future<void> completeProfile() async {
    if(currUser.isAdmin) {
      FirebaseDatabase.instance.reference().child('orgCode').push().set({
      currUser.orgName: currUser.orgCode
    });
    }

    UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: currUser.email,
          password: currUser.password,
          );

    String uid=userCredential.user!.uid;
    final prefs = await StreamingSharedPreferences.instance;
    var _eid = userCredential.user!.email!.length > 7
        ? userCredential.user!.email!.substring(0, 7)
        : userCredential.user!.uid.substring(0, 7);
    prefs.setString(_eid, currUser.orgCode);
    //final User? user=userCredential.user;
    print(fNameController.text+" "+sNameController.text);

    userCredential.user!.updateDisplayName(fNameController.text+" "+sNameController.text);
    //userCredential.user!.updatePhoneNumber(mobilePhoneController.text );
    await userCredential.user!.reload();
    final sp = await StreamingSharedPreferences.instance;
    sp.setString('Group', currUser.orgCode);
    sp.setString('GroupName', currUser.orgName);
    dbRef.child(currUser.orgCode).child("users").push().set({
      "email": currUser.email,
      "password":currUser.password,
      "isAdmin":currUser.isAdmin,
      "firstName": fNameController.text,
      "lastName": sNameController.text,
      "phoneNumber": mobilePhoneController.text,
      "address": addressController.text,
      "orgCode": currUser.orgCode,

    }


    ).then((user) => {
      if (uid != null) {
        print(fNameController.text+" "+sNameController.text),
      //  FirebaseAuth.instance.currentUser!.then((val){updateDisplayName(fNameController.text+" "+sNameController.text)}),

    print(uid),
        KeyboardUtil.hideKeyboard(context),
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                UserInfoPage(
                  user: FirebaseAuth.instance.currentUser as User,
                  orgCode: currUser.orgCode,
                ),
          ),
        )
      }
      else
        {
          FormError(errors: errors)
        }
    }); //Navigator.popAndPushNamed(context, Routes.home,arguments:userCredential));//TODO otp screen
  }
}
