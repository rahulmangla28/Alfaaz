import 'package:flutter/material.dart';
import 'package:alfaaz/config/custom_colors.dart';
import 'package:alfaaz/config/size_config.dart';

import 'package:alfaaz/pages/authentication/components/sign_in_body.dart';
import 'package:alfaaz/services/authentication/authentication.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
        appBar: AppBar(
          title: Text("Sign In"),
        ),
        body:  SignInBody(),//FutureBuilder(
    //     future: Authentication.initializeFirebase(context: context),
    //           builder: (context, snapshot) {
    //                 if (snapshot.hasError) {
    //                 return Text('Error initializing Firebase');
    //                 } else if (snapshot.connectionState ==
    //                 ConnectionState.done) {
    //                 return SignInBody();
    //                 }
    //           return CircularProgressIndicator(
    //           valueColor: AlwaysStoppedAnimation<Color>(
    //           CustomColors.firebaseOrange,
    //           ),
    //           );//SignInBody(),
    //
    // })
    );
    }
  }