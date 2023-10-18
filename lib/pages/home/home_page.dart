import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/routes/app_routes.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/*
This page initialises the application once the authentication is complete
It returns a a top level inherited widget to provide
theming information throughout your application.

https://getstream.io/chat/docs/flutter-dart/flutter_theming/?language=javascript
 */

class HomePageArgs {
  final StreamChatClient chatClient;

  HomePageArgs(this.chatClient);
}

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.chatClient,
  }) : super(key: key);

  final StreamChatClient chatClient;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      /// Top level Widget to set the theme of the application unless overridden
      client: widget.chatClient,
      streamChatThemeData: StreamChatThemeData(
        brightness: Theme.of(context).brightness,
        channelListHeaderTheme: const ChannelListHeaderThemeData(
          color: appBlueColor,

        ),
        colorTheme: Theme.of(context).brightness == Brightness.dark
            ? ColorTheme.dark(
          accentPrimary: appBlueColor,
        )
            : ColorTheme.light(
          accentPrimary: appBlueColor,

        ),

        messageInputTheme: const MessageInputThemeData(
          actionButtonColor: appBlueColor,
          actionButtonIdleColor: appBlueColor,
          sendButtonIdleColor: appBlueColor,
          sendButtonColor: appBlueColor,
        ),
        otherMessageTheme: MessageThemeData(
          messageBackgroundColor: StreamChatTheme.of(context)
              .colorTheme
              .accentInfo
              .withOpacity(0.5),
          messageBorderColor: StreamChatTheme.of(context)
              .colorTheme
              .accentInfo
              .withOpacity(0.5),
        ),
        ownMessageTheme: MessageThemeData(
          messageBackgroundColor: appBlueColor.withOpacity(0.5),
          messageBorderColor: appBlueColor,
        ),
        primaryIconTheme: const IconThemeData(color: appBlueColor),
      ),

      child: WillPopScope(
        onWillPop: () async {
          final canPop = await _navigatorKey.currentState?.maybePop() ?? false;
          return !canPop;
        },
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute: Routes.channel_list_page,
        ),
      ),
    );
  }
}
