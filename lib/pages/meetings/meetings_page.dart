import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class MeetingsPage extends StatelessWidget {
  const MeetingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                "Connect with your team",
                style: TextStyle(
                    color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            // SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      splashColor: appBlueColor,
                      tooltip: "Create a Meeting",
                      iconSize: 50,
                      icon: const FaIcon(FontAwesomeIcons.solidPlusSquare,
                          color: appBlueColor),
                      onPressed: (){
                        Navigator.pushNamed(
                          context,
                          Routes.create_meet,
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      "New Meeting",
                      style: TextStyle(
                        color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      splashColor: appBlueColor,
                      tooltip: "Join a Meeting",
                      iconSize: 50,
                      icon:
                          const FaIcon(FontAwesomeIcons.video, color: appBlueColor),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.join_meet,
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      "Join Meeting",
                      style: TextStyle(
                        color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: size.height * 0.05),
            const SizedBox(height: 50),

            SvgPicture.asset(
              "assets/icons/meeting_pg.svg",
              height: size.height * 0.35,
              alignment: Alignment.center,
            ),
            // Add Join Meeting
          ],
        ),
      ),
    );
  }
}
