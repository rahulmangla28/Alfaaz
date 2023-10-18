import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/ui/drawer.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateMeetingsPage extends StatefulWidget {
  const CreateMeetingsPage({Key? key}) : super(key: key);

  static joinMeet(String code) async {
    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false
      };
      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      }
      var options = JitsiMeetingOptions(room: code)
        ..userDisplayName = LeftDrawer.userName
        ..audioMuted = false
        ..videoMuted = true
        ..featureFlags.addAll(featureFlags);

      await JitsiMeet.joinMeeting(options,
      listener: JitsiMeetingListener(//todo to check
        onConferenceTerminated: (meesage) {
          Fluttertoast.showToast(msg: "Meeting has been ended by host!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,);

        },
      ));
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  _CreateMeetingsPageState createState() => _CreateMeetingsPageState();
}

class _CreateMeetingsPageState extends State<CreateMeetingsPage> {
  String code = "";
  createCode() {
    setState(() {
      code = const Uuid().v1().substring(0, 6);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Create Meeting',
          style: TextStyle(
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
              fontSize: 16.0),
        ),
        leading: const StreamBackButton(),
        backgroundColor: appBlueColor,
      ),
      backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(),
          const SizedBox(
            height: 40,
          ),
          Container(
            width: size.width * 0.4,
            height: size.height * 0.05,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: appBlueColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Code:",
                  style: TextStyle(
                    color:
                        StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    fontSize: 20.0,
                  ),
                ),
                SelectableText(
                  code,
                  style: const TextStyle(
                      color: appLightColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.05),

          SizedBox(
            height: 25,
          ),

          SvgPicture.asset(
            "assets/icons/new_meet.svg",
            height: size.height * 0.35,
          ),

          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () => createCode(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: appAccentIconColor,
              ),
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: Center(
                child: Text(
                  "Create Code",
                  style: TextStyle(
                    color:
                        StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          InkWell(
            onTap: () => CreateMeetingsPage.joinMeet(code),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: appAccentIconColor,
              ),
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              child: Center(
                child: Text(
                  "Join Meeting",
                  style: TextStyle(
                    color:
                        StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          // Add Join Meeting
        ],
      ),
    );
  }
}
