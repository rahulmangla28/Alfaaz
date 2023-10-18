import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/config/size_config.dart';
import 'package:alfaaz/pages/authentication/register/register_page.dart';
import 'package:alfaaz/pages/models/radio_group.dart';
import 'package:alfaaz/pages/ui/default_button.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:uuid/uuid.dart';

class UserType extends StatefulWidget {
  @override
  _userTypeState createState() => _userTypeState();
}

class _userTypeState extends State<UserType> {
  int _radioVal = -1;
  final TextEditingController _controller = TextEditingController();
  TextEditingController textController = TextEditingController();
  late String name;
  final _formKey = GlobalKey<FormState>();
  List<RadioItem> radioList = [
    RadioItem(id: 0, value: "Admin"),
    RadioItem(id: 1, value: "Member")
  ];
  String code = "";

  var lists;
  createCode() {
    setState(() {
      code = randomCode(8);
    });
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

        // key: _formKey,
        child: Column(
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
        const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text("Registering as: ", style: TextStyle(fontSize: 20))),
        // SingleChildScrollView(
        //  height: 160.0,
        RadioListTile(
          title: Text('Admin'),
          groupValue: _radioVal,
          activeColor: appBlueColor,
          value: 0,
          onChanged: (val) {
            setState(() {
              // radioItem = data.value ;
              _radioVal = 0;
              if (_radioVal == 0) createCode();
            });
          },
        ),
        RadioListTile(
          title: Text('Member'),
          groupValue: _radioVal,
          activeColor: appBlueColor,
          value: 1,
          onChanged: (val) {
            setState(() {
              // radioItem = data.value ;
              _radioVal = 1;
              //   if (_radioVal == 0) createCode();
            });
          },
        ),
        //    Column(
        //
        //     children: radioList
        //         .map((data) => RadioListTile(
        //
        //               title: Text(data.value),
        //               groupValue: _radioVal,
        //               activeColor: appBlueColor,
        //               value: data.id,
        //               onChanged: (val) {
        //                 setState(() {
        //                   // radioItem = data.value ;
        //                   _radioVal = data.id;
        //                   if (_radioVal == 0) createCode();
        //                 });
        //               },
        //             ))
        //         .toList(),
        //
        // ),
        SizedBox(height: getProportionateScreenHeight(10)),
        //Padding(padding: EdgeInsets.all(10.0)),
        Visibility(
          visible: (_radioVal == 0),
          child: TextFormField(
              controller: textController,
              onSaved: (newValue) => name = newValue!,
              onChanged: (value) {
                name = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "";
                } else if (value.length < 1) {
                  final scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      content:
                          const Text('Please enter your organisation name.'),
                      //    action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
                    ),
                  );
                  return "";
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "Organisation Name",
                hintText: "Enter your Organisation name",
                //  floatingLabelBehavior: FloatingLabelBehavior.always,
              )),
        ),
        SizedBox(
          height: getProportionateScreenHeight(10),
        ),
        Visibility(
            visible: (_radioVal == 0),
            child: Container(
                child: Column(children: [
              Text("Your Organisation Code: ${code}",
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 2,
              ),
              const Text(
                "Disclaimer: Please provide this code to all the members who want to register in your organisation.",
                style: TextStyle(fontSize: 12.0, color: Colors.red),
              ),
              SizedBox(height: 15)
            ]))),
        Visibility(
            visible: (_radioVal == 1),
            // child: Form(
            //     key: formKey,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Container(
                  child: PinCodeTextField(
                controller: _controller,
                autoDisposeControllers: false,
                length: 8,
                obscureText: true,
                obscuringCharacter: '*',
                blinkWhenObscuring: true,
                validator: (v) {
                  if (v!.length < 8) {
                    return "Please enter correct code!";
                  } else {
                    return "";
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 30,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                cursorColor: Colors.black,
                animationDuration: const Duration(milliseconds: 300),
                onChanged: (String value) {
                  print(value);
                  setState(() {
                    code = value;
                  });
                },
                onCompleted: (v) {
                  print("Completed");
                },
                appContext: context,
              )),
            )),
        SizedBox(
          height: 10,
        ),
        DefaultButton(
            text: "Continue",
            press: () async {
              print(_radioVal);
              bool f = true;

              if (_radioVal == 0) {
               // List<dynamic>? lists;
                Map<dynamic, dynamic> values;
                List<dynamic>? l;
                int ft = 0;
                String org = textController.text;
                FirebaseDatabase.instance
                    .reference()
                    .child('orgCode').once()
                    .then((DataSnapshot snap) {
                      print('abcd');
                  print(snap.value);
                  if (snap.exists) {
                    //ft=true;

                   values = snap.value;
                   print(values);
                   print(org);
                    values.forEach((key, values) {
                      if(key==org) ft=1;
                    });

                    if(ft==1){
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'This organisation name already exists!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage(
                                  isAdmin: _radioVal,
                                  orgCode: code,
                                  orgName: org)));
                    }
                    }
                  }
                );

              } else if (_radioVal == 1) {
                print("code: $code");
                // DatabaseReference ref=
                DatabaseReference ref = await FirebaseDatabase.instance
                    .reference()
                    .child("organisation")
                    .child(code);
                //if(ref.child(code).child("users").) print("success");
                //.then((DataSnapshot snapshot){
                ref.once().then((DataSnapshot snap) {
                  print(snap.value);
                  f = snap.exists;
                  print(f);
                  if (!snap.exists) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Wrong Organisation Code.',
                            style: TextStyle(color: Colors.red)),
                        content: const Text(
                          'Organisation doesn\'t exist',
                          style: TextStyle(color: Colors.red),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );

                    // print("Item doesn't exist in the db");
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RegisterPage(
                              isAdmin: _radioVal,
                              orgCode: code,
                              orgName: "todo",
                            ))); //todo
                  }
                });
              }

            }),
      ],
    ));
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  String randomCode(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    var random = Random.secure();

    String code = String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(random.nextInt(_chars.length))));
    return code;
  }
}
