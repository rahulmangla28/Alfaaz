import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_info_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_media_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_page.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../chat_info_page.dart';

/*
Option Tile Widgets for info screen of channels and private chats.
Generalised and Modular Tiles implemented
*/


class MediaOptionsTile extends StatelessWidget {
  const MediaOptionsTile({
    Key? key,
    required this.context,
    this.channelWidget,
    this.chatWidget,
  }) : super(key: key);

  final BuildContext context;
  final ChannelInfoPage? channelWidget;
  final ChatInfoPage? chatWidget;

  @override
  Widget build(BuildContext context) {
    return OptionListTile(
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
      title: 'Photos & Videos',
      titleTextStyle: StreamChatTheme.of(context).textTheme.body,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: StreamSvgIcon.pictures(
          size: 32.0,
          color: appAccentIconColor,
        ),
      ),
      trailing: StreamSvgIcon.right(
        color: appLightColor,
      ),
      onTap: () {
        var channel = StreamChannel.of(context).channel;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreamChannel(
              channel: channel,
              child: MessageSearchBloc(
                child: ChannelMediaPage(
                  //Added Modularity
                  messageThemeData: chatWidget == null
                      ? channelWidget!.messageTheme
                      : chatWidget!.messageTheme,
                  sortOptions: const [
                    SortOption(
                      'created_at',
                      direction: SortOption.ASC,
                    ),
                  ],
                  paginationParams: const PaginationParams(limit: 20),
                  onShowMessage: (m, c) async {
                    final client = StreamChat.of(context).client;
                    final message = m;
                    final channel = client.channel(
                      c.type,
                      id: c.id,
                    );
                    if (channel.state == null) {
                      await channel.watch();
                    }
                    await Navigator.pushNamed(
                      context,
                      Routes.channel_page,
                      arguments: ChannelPageArgs(
                        channel: channel,
                        initialMessage: message,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}