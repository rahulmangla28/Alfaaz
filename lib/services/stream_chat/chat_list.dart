import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/chat_info_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_info_page.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_page.dart';
import 'package:alfaaz/pages/ui/search_text_field.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/*
This page creates the list of channels or conversation chats a user has, to
be displayed on the chat home page
*/

class ChannelList extends StatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  _ChannelList createState() => _ChannelList();
}

class _ChannelList extends State<ChannelList> {
  TextEditingController? _controller;

  String _channelQuery = '';

  bool _isSearchActive = false;

  Timer? _debounce;

  void _channelQueryListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _channelQuery = _controller!.text;
          _isSearchActive = _channelQuery.isNotEmpty;
        });
      }
    });
  }

  @override
  void initState() {
    ///The function will call this method exactly once for each State object it creates.
    super.initState();
    _controller = TextEditingController()..addListener(_channelQueryListener);
  }

  @override
  void dispose() {
    ///The function calls this method when this State object will never build again.
    _controller?.removeListener(_channelQueryListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = StreamChat.of(context).currentUser;
    return WillPopScope(
      /*
      Creates a widget that registers a callback to veto attempts by the user
      to dismiss the enclosing ModalRoute.
       */
      onWillPop: () async {
        if (_isSearchActive) {
          _controller!.clear();
          setState(() => _isSearchActive = false);
          return false;
        }
        return true;
      },
      child: ChannelsBloc(
        child: MessageSearchBloc(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(
                child: SearchTextField(
                  controller: _controller,
                  showCloseButton: _isSearchActive,
                ),
              ),
            ],
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) => FocusScope.of(context).unfocus(),
                child: _isSearchActive
                    ? MessageSearchListView(
                  showErrorTile: true,
                  messageQuery: _channelQuery,
                  filters: Filter.in_('members', [user!.id]),
                  sortOptions: const [
                    SortOption(
                      'created_at',
                      direction: SortOption.ASC,
                    ),
                  ],
                  pullToRefresh: false,

                  limit: 20,
                  emptyBuilder: (_) {
                    return LayoutBuilder(
                      builder: (context, viewportConstraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: viewportConstraints.maxHeight,
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: StreamSvgIcon.search(
                                      size: 96,
                                      color: appAccentColor,
                                    ),
                                  ),
                                  const Text(
                                    'No results...',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  onItemTap: (messageResponse) async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final client = StreamChat.of(context).client;
                    final message = messageResponse.message;
                    final channel = client.channel(
                      messageResponse.channel!.type,
                      id: messageResponse.channel!.id,
                    );
                    if (channel.state == null) {
                      await channel.watch();
                    }
                    Navigator.pushNamed(
                      context,
                      Routes.channel_page,
                      arguments: ChannelPageArgs(
                        channel: channel,
                        initialMessage: message,
                      ),
                    );
                  },
                )
                    : ChannelListView(
                  onStartChatPressed: () {
                    Navigator.pushNamed(context, Routes.new_chat);
                  },
                  swipeToAction: true,
                  filter: Filter.in_('members', [user!.id]),
                  presence: true,
                  limit: 20,
                  channelWidget: const ChannelPage(),
                  onViewInfoTap: (channel) {
                    Navigator.pop(context);
                    if (channel.memberCount == 2 && channel.isDistinct) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StreamChannel(
                            channel: channel,
                            child: ChatInfoPage(
                              messageTheme: StreamChatTheme.of(context)
                                  .ownMessageTheme,
                              user: channel.state!.members
                                  .where((m) =>
                              m.userId !=
                                  channel.client.state.currentUser!.id)
                                  .first
                                  .user,
                            ),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StreamChannel(
                            channel: channel,
                            child: ChannelInfoPage(
                              messageTheme: StreamChatTheme.of(context)
                                  .ownMessageTheme,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}