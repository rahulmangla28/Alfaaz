import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/user_mentions.dart';
import 'package:alfaaz/pages/meetings/meetings_page.dart';
import 'package:alfaaz/pages/ui/drawer.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:alfaaz/services/stream_chat/stream_chat_api.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';


import '../../services/stream_chat/chat_list.dart';

class ChatsHomePage extends StatefulWidget {
  const ChatsHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _ChatsHomePageState createState() => _ChatsHomePageState();
}

class _ChatsHomePageState extends State<ChatsHomePage> {
  int _currentIndex = 0;

  bool _isSelected(int index) => _currentIndex == index;

  List<BottomNavigationBarItem> get _navBarItems {
    return <BottomNavigationBarItem>[
      // Icon for Join meetings page
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            StreamSvgIcon.iconGroup(
              color: _isSelected(0) ? appAccentColor : Colors.grey,
            ),
          ],
        ),
        label: 'Meetings',
      ),
      // Icon for user chats page
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            StreamSvgIcon.message(
              color: _isSelected(1) ? appAccentColor : Colors.grey,
            ),
            Positioned(
              top: -3,
              right: -16,
              child: UnreadIndicator(),
            ),
          ],
        ),
        label: 'Chats',
      ),
      // Icon for user mentions page
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            StreamSvgIcon.mentions(
              color: _isSelected(2) ? appAccentColor : Colors.grey,
            ),
          ],
        ),
        label: 'Mentions',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = StreamChat.of(context).currentUser;
    //print(user);
    if (user == null) {
      return const Offstage();
    }
    return Scaffold(
      //scaffold for search box
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: ChannelListHeader(
        titleBuilder: (context, connectionStatus, streamClient) {
          var status = StreamApi.kDefaultStreamClient.wsConnectionStatus;
          if (status == ConnectionStatus.connecting) {
            return Text(
              'Connecting...',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                  fontSize: 16.0),
            );
          }
          return Text(
            'Smile',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                fontSize: 16.0),
          );
        },
        onNewChatButtonTap: () {
          Navigator.pushNamed(context, Routes.new_chat);
        },
        preNavigationCallback: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
      drawer: LeftDrawer(
        user: user,
      ),
      drawerEdgeDragWidth: 50,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        currentIndex: _currentIndex,
        items: _navBarItems,
        selectedLabelStyle: StreamChatTheme.of(context).textTheme.footnoteBold,
        unselectedLabelStyle:
        StreamChatTheme.of(context).textTheme.footnoteBold,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      body: IndexedStack(
        // To map the indexes of Pages with Bottom Navigation Bar icons
        index: _currentIndex,
        children: [
          const MeetingsPage(),
          const ChannelList(),
          UserMentionsPage(),
        ],
      ),
    );
  }

  StreamSubscription<int>? badgeListener;

  @override
  void initState() {
    badgeListener = StreamChat.of(context)
        .client
        .state
        .totalUnreadCountStream
        .listen((count) {
      if (count > 0) {
        FlutterAppBadger.updateBadgeCount(count);
      } else {
        FlutterAppBadger.removeBadge();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    badgeListener?.cancel();
    super.dispose();
  }
}