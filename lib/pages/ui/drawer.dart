import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/home/developer_info.dart';
import 'package:alfaaz/routes/app_routes.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:alfaaz/services/authentication/authentication.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:recase/recase.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;
  static String? userName;

  @override
  Widget build(BuildContext context) {
    // print("usera");
    print(user);
    //userName = user.name;
    return Drawer(
      child: Container(
        //    color: StreamChatTheme.of(context).colorTheme.white,
        child: SafeArea(
          // child: SizedBox(c)
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 4,
                ),
                child: Container(
                  color: appBlueColor,
                  height: MediaQuery.of(context).viewPadding.top + 40,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      UserAvatar(
                        user: user,
                        showOnlineStatus: false,
                        constraints: BoxConstraints.tight(Size.fromRadius(20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Hello,\n" + user.name.titleCase,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: StreamSvgIcon.iconGroup(
                  color: appAccentColor.withOpacity(.8),
                ),
                onTap: () {
                  Navigator.popAndPushNamed(
                    context,
                    Routes.create_meet,
                  );
                },
                title: Text(
                  'New meeting',
                  style: TextStyle(
                    fontSize: 14.5,
                  ),
                ),
              ),
              ListTile(
                leading: StreamSvgIcon.penWrite(
                  color: appAccentColor.withOpacity(.8),
                ),
                onTap: () {
                  Navigator.popAndPushNamed(
                    context,
                    Routes.new_chat,
                  );
                },
                title: Text(
                  'New message',
                  style: TextStyle(
                    fontSize: 14.5,
                  ),
                ),
              ),
              ListTile(
                leading: StreamSvgIcon.userAdd(
                  color: appAccentColor.withOpacity(.8),
                ),
                onTap: () {
                  Navigator.popAndPushNamed(
                    context,
                    Routes.new_channel,
                  );
                },
                title: Text(
                  'New group',
                  style: TextStyle(
                    fontSize: 14.5,
                  ),
                ),
              ),
              ListTile(
                leading: StreamSvgIcon.user(
                  color: appAccentColor.withOpacity(.8),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => DeveloperInfo()));
                },
                title: Text(
                  'Developer Info',
                  style: TextStyle(
                    fontSize: 14.5,
                  ),
                ),
              ),
              // Divider(
              //   // color: StreamChatTheme.of(context)
              //   //     .colorTheme
              //   //     .black
              //   //     .withOpacity(0.3),
              //   thickness: 0.5,
              //   height: 20,
              // ),
              // Text(
              //   'Developed by Rahul Mangla',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontSize: 10.5, color: Colors.grey),
              // ),
              // Divider(
              //   //  color: StreamChatTheme.of(context).colorTheme.overlay.withAlpha(1)
              //
              //   //   .withOpacity(0.3),
              //   thickness: 0.5,
              //   height: 20,
              // ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      // TODO LOGOUT FUNCTIONALITY
                      final secureStorage = FlutterSecureStorage();
                      await secureStorage.deleteAll();

                      final client = StreamChat.of(context).client;
                      client.disconnectUser();
                      await client.dispose();
                      await Authentication.signOut(context: context);
                      await Navigator.of(context)
                          .pushReplacement(routeToSignInPage());
                    },
                    // leading: StreamSvgIcon.userRemove(
                    //   color: appAccentColor,
                    // ),
                    title: Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 14.5,
                      ),
                    ),
                    trailing: IconButton(
                      icon: StreamSvgIcon.iconMoon(
                        size: 24,
                      ),
                      color: StreamChatTheme.of(context).colorTheme.appBg,
                      onPressed: () async {
                        final sp = await StreamingSharedPreferences.instance;
                        sp.setInt(
                          'theme',
                          Theme.of(context).brightness == Brightness.dark
                              ? 1
                              : -1,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
