import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/group_chat/channel_page.dart';
import 'package:alfaaz/routes/ui_routes.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../models/globals.dart' as globals;
import '../thread.dart';
import 'chips_input_text_field.dart';

/*
This page renders the UI for the new chat page and integrates the BusinessLogic
to start personal chats or create new channels with other members.
*/

class NewChatPage extends StatefulWidget {
  const NewChatPage({Key? key}) : super(key: key);

  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final _chipInputTextFieldStateKey =
  GlobalKey<ChipInputTextFieldState<User>>();

  late TextEditingController _controller;

  ChipInputTextFieldState? get _chipInputTextFieldState =>
      _chipInputTextFieldStateKey.currentState;

  String _userNameQuery = '';

  final _selectedUsers = <User>{};

  final _searchFocusNode = FocusNode();
  final _messageInputFocusNode = FocusNode();

  bool _isSearchActive = false;

  Channel? channel;

  Timer? _debounce;

  bool _showUserList = true;

  Message? _quotedMessage;
  void _reply(Message message) {
    setState(() => _quotedMessage = message);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _messageInputFocusNode.requestFocus();
    });
  }

  void _userNameListener() {
    /*
    Sets the listener for the user name
    * */
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _userNameQuery = _controller.text;
          _isSearchActive = _userNameQuery.isNotEmpty;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print(globals.organisationCode);
    channel = StreamChat.of(context).client.channel('messaging');
    _controller = TextEditingController()..addListener(_userNameListener);

    _searchFocusNode.addListener(() async {
      if (_searchFocusNode.hasFocus && !_showUserList) {
        setState(() {
          _showUserList = true;
        });
      }
    });

    _messageInputFocusNode.addListener(() async {
      if (_messageInputFocusNode.hasFocus && _selectedUsers.isNotEmpty) {
        final chatState = StreamChat.of(context);

        final res = await chatState.client.queryChannelsOnline(
          state: false,
          watch: false,
          filter: Filter.raw(value: {
            'members': [
              ..._selectedUsers.map((e) => e.id),
              chatState.currentUser!.id,
            ],
            'distinct': true,
          }),
          messageLimit: 0,
          paginationParams: const PaginationParams(
            limit: 1,
          ),
        );

        final _channelExisted = res.length == 1;
        if (_channelExisted) {
          channel = res.first;
          await channel!.watch();
        } else {
          channel = chatState.client.channel(
            'messaging',
            extraData: {
              'members': [
                ..._selectedUsers.map((e) => e.id),
                chatState.currentUser!.id,
              ],
            },
          );
          channel!.create();
         await channel!.watch();
        }
       // await channel!.watch();
        setState(() {
          _showUserList = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _messageInputFocusNode.dispose();
    _controller.clear();
    _controller.removeListener(_userNameListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: appBlueColor,
        leading: const StreamBackButton(),
        title: Text(
          'New Chat',
          style: StreamChatTheme.of(context).textTheme.headlineBold.copyWith(
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis),
        ),
        centerTitle: true,
      ),
      body: ConnectionStatusBuilder(

        ///  Sets the Internet Connection Status on the basis of the state of the server

        statusBuilder: (context, status) {
          String statusString = '';
          bool showStatus = true;

          switch (status) {
            case ConnectionStatus.connected:
              statusString = 'Connected';
              showStatus = false;
              break;
            case ConnectionStatus.connecting:
              statusString = 'Reconnecting...';
              break;
            case ConnectionStatus.disconnected:
              statusString = 'Disconnected';
              break;
          }
          return InfoTile(
            showMessage: showStatus,
            tileAnchor: Alignment.topCenter,
            childAnchor: Alignment.topCenter,
            message: statusString,
            child: StreamChannel(
              showLoading: false,
              channel: channel!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChipsInputTextField<User>(
                    key: _chipInputTextFieldStateKey,
                    controller: _controller,
                    focusNode: _searchFocusNode,
                    chipBuilder: (context, user) {
                      return GestureDetector(
                        onTap: () {
                          _chipInputTextFieldState?.removeItem(user);
                          _searchFocusNode.requestFocus();
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: appLightColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.only(left: 24),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                                child: Text(
                                  user.name,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: StreamChatTheme.of(context)
                                        .colorTheme
                                        .textHighEmphasis,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              foregroundDecoration: BoxDecoration(
                                color: StreamChatTheme.of(context)
                                    .colorTheme
                                    .overlay,
                                shape: BoxShape.circle,
                              ),
                              child: UserAvatar(
                                showOnlineStatus: true,
                                user: user,
                                constraints: const BoxConstraints.tightFor(
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                            StreamSvgIcon.close(
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textHighEmphasis,
                            ),
                          ],
                        ),
                      );
                    },
                    onChipAdded: (user) {
                      setState(() => _selectedUsers.add(user));
                    },
                    onChipRemoved: (user) {
                      setState(() => _selectedUsers.remove(user));
                    },
                  ),
                  if (!_isSearchActive && !_selectedUsers.isNotEmpty)
                    const CreateGroupTile(),
                  if (_showUserList)
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient:
                        StreamChatTheme.of(context).colorTheme.bgGradient,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        child: Text(
                            _isSearchActive
                                ? "Matches for \"$_userNameQuery\""
                                : 'On the platform',
                            style: StreamChatTheme.of(context)
                                .textTheme
                                .footnote
                                .copyWith(
                                color: StreamChatTheme.of(context)
                                    .colorTheme
                                    .textHighEmphasis
                                    .withOpacity(.5))),
                      ),
                    ),
                  Expanded(

                    child: _showUserList
                        ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (_) => FocusScope.of(context).unfocus(),
                      child: UsersBloc(
                        child: UserListView(
                          selectedUsers: _selectedUsers,
                          groupAlphabetically:
                          _isSearchActive ? false : true,
                          onUserTap: (user, _) {
                            _controller.clear();
                            if (!_selectedUsers.contains(user)) {
                              _chipInputTextFieldState
                                ?..addItem(user)
                                ..pauseItemAddition();

                            } else {
                              _chipInputTextFieldState!.removeItem(user);
                            }
                          },
                          limit: 20,// todo
                          filter: Filter.and([
                            if (_userNameQuery.isNotEmpty)
                              Filter.autoComplete('name', _userNameQuery),
                            Filter.equal('orgCode', globals.organisationCode),
                            Filter.notEqual(
                                'id', StreamChat.of(context).currentUser!.id),
                          ]),
                          sort: const [
                            SortOption(
                              'name',
                              direction: 1,
                            ),
                          ],
                          emptyBuilder: (_) {
                            return LayoutBuilder(
                              builder: (context, viewportConstraints) {
                                return SingleChildScrollView(
                                  physics:
                                  AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight:
                                      viewportConstraints.maxHeight,
                                    ),
                                    child: NoUserMatch(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    )
                        : FutureBuilder<bool>(
                      future: channel!.initialized,
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return MessageListView();
                        }

                        return const Center(
                          child: Text(
                            'No chats here yet...',
                            style: TextStyle(
                              fontSize: 12,
                              color: appLightColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  MessageInput(

                     focusNode: _messageInputFocusNode,
                   //  quotedMessage: _quotedMessage,
                   //  onQuotedMessageCleared: () {
                   //    setState(() => _quotedMessage = null);
                   //  },

                    preMessageSending: (message) async {
                      return message;
                    },

                    onMessageSent: (m) async {

                      Navigator.pushNamed(
                        context,
                        Routes.channel_page,
                        //ModalRoute.withName(Routes.home),
                        arguments: ChannelPageArgs(channel: channel),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NoUserMatch extends StatelessWidget {
  const NoUserMatch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: StreamSvgIcon.search(
              size: MediaQuery.of(context).size.height*0.3,
              color: appLightColor,
            ),
          ),
          Text(
            'No user matches these keywords...',
            style: StreamChatTheme.of(context)
                .textTheme
                .footnote
                .copyWith(color: appLightColor),
          ),
        ],
      ),
    );
  }
}
/// Create 'create a group' on new chat screen
class CreateGroupTile extends StatelessWidget {
  const CreateGroupTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.new_channel,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 7,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: StreamSvgIcon.contacts(
                color: appAccentIconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Create a Group',
              style: StreamChatTheme.of(context).textTheme.bodyBold,
            ),
            SizedBox(width: 3),
            Center(
              child: StreamSvgIcon.right(
                color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}