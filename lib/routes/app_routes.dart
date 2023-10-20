import 'package:flutter/material.dart';
import 'package:alfaaz/pages/authentication/complete_profile/complete_profile_screen.dart';
import 'package:alfaaz/pages/authentication/forget_password_screen.dart';
import 'package:alfaaz/pages/authentication/otp/otp_screen.dart';
import 'package:alfaaz/pages/authentication/register/register_page.dart';
import 'package:alfaaz/pages/authentication/register/user_type_page.dart';
import 'package:alfaaz/pages/authentication/sign_in_page.dart';
import 'package:alfaaz/pages/chat/chat_info_page.dart';
import 'package:alfaaz/pages/chat/chats_home_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_info_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_name_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_page.dart';
import 'package:alfaaz/pages/chat/new_chat/add_channel_members.dart';
import 'package:alfaaz/pages/chat/new_chat/new_chat_screen.dart';
import 'package:alfaaz/pages/home/home_page.dart';
import 'package:alfaaz/pages/introduction_animation/introduction_animation.dart';
import 'package:alfaaz/pages/meetings/create_meetings_page.dart';
import 'package:alfaaz/pages/meetings/join_meetings_page.dart';
import 'package:alfaaz/pages/meetings/meetings_page.dart';
import 'package:alfaaz/pages/models/register_model.dart';
import 'package:alfaaz/services/stream_chat/chat_list.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'ui_routes.dart';

class AppRoutes {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.intro:
        return MaterialPageRoute(builder: (_) {
          return IntroductionAnimationScreen();
        });
      case Routes.login:
        return MaterialPageRoute(builder: (_) {
          return LoginPage();
        });
      case Routes.register:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.register),
            builder: (_) {
              // final registerArgs= args as RegisterPageArgs;
              return RegisterPage(
                isAdmin: 1,
                orgCode: "",
                orgName: "",
              );
            });
      case Routes.forget_password:
        return MaterialPageRoute(builder: (_) {
          return ForgetPasswordScreen();
        });
      case Routes.complete_profile_screen:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.register),
            builder: (_) {
              final userArgs = args as RegisterModel;
              return CompleteProfileScreen(
                newUser: userArgs,
              );
            });
      case Routes.otp_screen:
        return MaterialPageRoute(builder: (_) {
          return OtpScreen();
        });
      case Routes.home:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.home),
            builder: (_) {
              final homePageArgs = args as HomePageArgs;
              return HomePage(
                chatClient: homePageArgs.chatClient,
              );
            });
      case Routes.user_type:
        return MaterialPageRoute(builder: (_) {
          return UserTypePage();
        });

      case Routes.create_meet:
        return MaterialPageRoute(builder: (_) {
          return CreateMeetingsPage();
        });
      case Routes.meet:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.choose_user),
            builder: (_) {
              return MeetingsPage();
            });
      case Routes.join_meet:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.choose_user),
            builder: (_) {
              return JoinMeetingsPage();
            });

      case Routes.channel_page:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.channel_page),
            builder: (_) {
              final channelPageArgs = args as ChannelPageArgs;
              return StreamChannel(
                channel: channelPageArgs.channel!,
                initialMessageId: channelPageArgs.initialMessage?.id,
                child: ChannelPage(
                  highlightInitialMessage:
                      channelPageArgs.initialMessage != null,
                ),
              );
            });
      case Routes.new_chat:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.new_chat),
            builder: (_) {
              return NewChatPage();
            });
      case Routes.new_channel:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.new_channel),
            builder: (_) {
              return AddChannelMembersPage();
            });
      case Routes.new_channel_details:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.new_channel_details),
            builder: (_) {
              return ChannelNamePage(
                selectedUsers: args as List<User>?,
              );
            });

      case Routes.chat_info_screen:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.chat_info_screen),
            builder: (context) {
              return ChatInfoPage(
                user: args as User?,
                messageTheme: StreamChatTheme.of(context).ownMessageTheme,
              );
            });
      case Routes.group_info_screen:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.group_info_screen),
            builder: (context) {
              return ChannelInfoPage(
                messageTheme: StreamChatTheme.of(context).ownMessageTheme,
              );
            });
      case Routes.channel_list_page:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.channel_list_page),
            builder: (context) {
              return ChatsHomePage();
            });
      case Routes.channel_list:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.channel_list),
            builder: (context) {
              return ChannelList();
            });
    }
  }
}

Route routeToSignInPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
