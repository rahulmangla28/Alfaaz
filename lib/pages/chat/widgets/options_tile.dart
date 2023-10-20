import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_file_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';


///Option Tile Widgets for info screen of channels and private chats.
///Generalised and Modular Tiles implemented


class FilesOptionTile extends StatelessWidget {
  const FilesOptionTile({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;
  @override
  Widget build(BuildContext context) {
    return OptionListTile(
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
      title: 'Files',
      titleTextStyle: StreamChatTheme.of(context).textTheme.body,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: StreamSvgIcon.files(
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
                child: ChannelFilePage(
                  sortOptions: [
                    SortOption(
                      'created_at',
                      direction: SortOption.ASC,
                    ),
                  ],
                  paginationParams: PaginationParams(limit: 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}