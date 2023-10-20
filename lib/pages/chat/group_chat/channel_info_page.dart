import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/widgets/media_option_tile.dart';
import 'package:alfaaz/pages/chat/widgets/mute_option_tile.dart';
import 'package:alfaaz/pages/chat/widgets/options_tile.dart';
import 'package:alfaaz/pages/chat/widgets/pin_option_tile.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../models/globals.dart' as globals;
import '../chat_info_page.dart';
import 'channel_page.dart';

///This page renders the information screen for the channel
///and sets the tiles for files, media screen and other group related options


class ChannelInfoPage extends StatefulWidget {
  final MessageThemeData messageTheme;

  const ChannelInfoPage({
    Key? key,
    required this.messageTheme,
  }) : super(key: key);

  @override
  _ChannelInfoPageState createState() => _ChannelInfoPageState();
}

class _ChannelInfoPageState extends State<ChannelInfoPage> {
  TextEditingController? _nameController;

  TextEditingController? _searchController;
  String _userNameQuery = '';

  Timer? _debounce;
  Function? modalSetStateCallback;

  final FocusNode _focusNode = FocusNode();

  bool listExpanded = false;

  ValueNotifier<bool?> mutedBool = ValueNotifier(false);

  void _userNameListener() {
    if (_searchController!.text == _userNameQuery) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted && modalSetStateCallback != null) {
        modalSetStateCallback!(() {
          _userNameQuery = _searchController!.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    var channel = StreamChannel.of(context);
    _nameController = TextEditingController.fromValue(
      TextEditingValue(
          text: (channel.channel.extraData['name'] as String?) ?? ''),
    );
    _searchController = TextEditingController()..addListener(_userNameListener);

    _nameController!.addListener(() {
      setState(() {});
    });
    mutedBool = ValueNotifier(StreamChannel.of(context).channel.isMuted);
  }

  @override
  Widget build(BuildContext context) {
    var channel = StreamChannel.of(context);

    return StreamBuilder<List<Member>>(
        /*
          * Creates a new StreamBuilder that builds itself based on the latest
          * snapshot of interaction with the specified stream and whose
          * build strategy is given by builder.
          * */
        stream: channel.channel.state!.membersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: StreamChatTheme.of(context).colorTheme.disabled,
              child: Center(
                  child: CircularProgressIndicator(
                color: appAccentColor,
              )),
            );
          }

          var userMember = snapshot.data!.firstWhereOrNull(
            (e) => e.user!.id == StreamChat.of(context).currentUser!.id,
          );
          var isOwner = userMember?.role == 'owner';

          return Scaffold(
            backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
            appBar: AppBar(
              systemOverlayStyle:
                  Theme.of(context).brightness == Brightness.dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark,
              elevation: 1.0,
              toolbarHeight: 56.0,
              backgroundColor: appBlueColor,
              leading: StreamBackButton(),
              title: Column(
                children: [
                  StreamBuilder<ChannelState>(
                      /*
          * Creates a new StreamBuilder that builds itself based on the latest
          * snapshot of interaction with the specified stream and whose
          * build strategy is given by builder.
          * */
                      stream: channel.channelStateStream,
                      builder: (context, state) {
                        if (!state.hasData) {
                          return Text(
                            'Loading...',
                            style: TextStyle(
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textHighEmphasis,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }

                        return Text(
                          _getChannelName(
                            2 * MediaQuery.of(context).size.width / 3,
                            members: snapshot.data,
                            extraData: state.data!.channel!.extraData,
                            maxFontSize: 16.0,
                          )!,
                          style: TextStyle(
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    '${channel.channel.memberCount} Members, '
                    '${snapshot.data?.where((e) => e.user!.online).length ?? 0} Online',
                    style: TextStyle(
                      color: StreamChatTheme.of(context)
                          .colorTheme
                          .textHighEmphasis
                          .withOpacity(0.5),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                if (!channel.channel.isDistinct && isOwner)
                  StreamNeumorphicButton(
                    child: InkWell(
                      onTap: () {
                        _buildAddUserModal(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamSvgIcon.userAdd(color: appAccentIconColor),
                      ),
                    ),
                  ),
              ],
            ),
            body: ListView(
              children: [
                _buildMembers(snapshot.data!),
                Container(
                  height: 8.0,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                if (isOwner) _buildNameTile(),
                _buildOptionListTiles(),
              ],
            ),
          );
        });
  }
/// Build list of members in the group
  Widget _buildMembers(List<Member> members) {
    final groupMembers = members
      ..sort((prev, curr) {
        if (curr.role == 'owner') return 1;
        return 0;
      });

    int groupMembersLength;

    if (listExpanded) {
      groupMembersLength = groupMembers.length;
    } else {
      groupMembersLength = groupMembers.length > 6 ? 6 : groupMembers.length;
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupMembersLength,
          itemBuilder: (context, index) {
            final member = groupMembers[index];
            return Material(
              child: InkWell(
                onTap: () {
                  final userMember = groupMembers.firstWhereOrNull(
                    (e) => e.user!.id == StreamChat.of(context).currentUser!.id,
                  );
                  _showUserInfoModal(member.user, userMember?.role == 'owner');
                },
                child: Container(
                  height: 65.0,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            child: UserAvatar(
                              user: member.user!,
                              constraints: const BoxConstraints(
                                  maxHeight: 40.0, maxWidth: 40.0),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  member.user!.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 1.0,
                                ),
                                Text(
                                  _getLastSeen(member.user!),
                                  style: TextStyle(
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .textHighEmphasis
                                          .withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              member.role == 'owner' ? 'Owner' : '',
                              style: TextStyle(
                                  color: StreamChatTheme.of(context)
                                      .colorTheme
                                      .disabled
                                      .withOpacity(0.5)),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 1.0,
                        color: StreamChatTheme.of(context).colorTheme.disabled,
                      ),
                    ],
                  ),
                ),
              ),
              color: StreamChatTheme.of(context).colorTheme.appBg,
            );
          },
        ),
        if (groupMembersLength != groupMembers.length)
          InkWell(
            onTap: () {
              setState(() {
                listExpanded = true;
              });
            },
            child: Material(
              color: StreamChatTheme.of(context).colorTheme.appBg,
              child: Container(
                height: 65.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 21.0, vertical: 12.0),
                            child: StreamSvgIcon.down(
                              color: appLightColor,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${members.length - groupMembersLength} more',
                                  style: TextStyle(
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .textLowEmphasis),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1.0,
                      color: StreamChatTheme.of(context).colorTheme.disabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameTile() {
    ///Renders the tiles for each member name of the group
    var channel = StreamChannel.of(context).channel;
    var channelName = (channel.extraData['name'] as String?) ?? '';

    return Material(
      color: StreamChatTheme.of(context).colorTheme.appBg,
      child: Container(
        height: 56.0,
        alignment: Alignment.center,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: StreamSvgIcon.user(
                size: 24.0,
                color: appAccentIconColor,
              ),
            ),
            const SizedBox(
              width: 7.0,
            ),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _nameController,
                cursorColor:
                    StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                decoration: InputDecoration.collapsed(
                    hintText: 'Add a group name',
                    hintStyle: StreamChatTheme.of(context)
                        .textTheme
                        .bodyBold
                        .copyWith(
                            color: StreamChatTheme.of(context)
                                .colorTheme
                                .textHighEmphasis
                                .withOpacity(0.5))),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  height: 0.82,
                ),
              ),
            ),
            if (channelName != _nameController!.text.trim())
              // Trims the channel name incase string length is long
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    child: StreamSvgIcon.closeSmall(
                      color: StreamChatTheme.of(context).colorTheme.accentError,
                    ),
                    onTap: () {
                      setState(() {
                        _nameController!.text = _getChannelName(
                          2 * MediaQuery.of(context).size.width / 3,
                          members: channel.state!.members,
                          extraData: channel.extraData,
                          maxFontSize: 16.0,
                        )!;
                        _focusNode.unfocus();
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                    child: InkWell(
                      child: StreamSvgIcon.check(
                        color: appAccentIconColor,
                        size: 24.0,
                      ),
                      onTap: () {
                        StreamChannel.of(context).channel.update({
                          'name': _nameController!.text.trim(),
                        }).catchError((err) {
                          setState(() {
                            _nameController!.text = channelName;
                            _focusNode.unfocus();
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionListTiles() {
    var channel = StreamChannel.of(context);

    return Column(
      children: [

        StreamBuilder<bool>(
          /*
          * Creates a new StreamBuilder that builds itself based on the latest
          * snapshot of interaction with the specified stream and whose
          * build strategy is given by builder.
          * */
          stream: StreamChannel.of(context).channel.isMutedStream,
          builder: (context, snapshot) {
            mutedBool.value = snapshot.data;
            return MuteOptionTile(
              // Modular Widget
              text: 'Mute Group',
              trailingWidget: snapshot.data == null
                  ? CircularProgressIndicator(
                      color: appAccentColor,
                    )
                  : ValueListenableBuilder<bool?>(
                      valueListenable: mutedBool,
                      builder: (context, value, _) {
                        return CupertinoSwitch(
                          // Sliding switch
                          activeColor: appAccentIconColor,
                          value: value!,
                          onChanged: (val) {
                            mutedBool.value = val;

                            if (snapshot.data!) {
                              channel.channel.unmute();
                            } else {
                              channel.channel.mute();
                            }
                          },
                        );
                      },
                    ),
            );
          },
        ),
        PinOptionTile(
          context: context,
          channelWidget: widget,
        ),
        MediaOptionsTile(
          context: context,
          channelWidget: widget,
        ),
        FilesOptionTile(context: context),
        if (!channel.channel.isDistinct) LeaveOptionTile(context: context),
      ],
    );
  }
  /// build the widget to display the list of users not in the group
  void _buildAddUserModal(context) {
    var channel = StreamChannel.of(context).channel;

    showDialog(
      /// when clicking on add new user inside the group
      ///Displays a Material dialog above the current contents of the app, with Material entrance
      ///  and exit animations, modal barrier color, and modal barrier behavior
      useRootNavigator: false,
      context: context,
      barrierColor: StreamChatTheme.of(context).colorTheme.overlay,
      builder: (context) {
        return StatefulBuilder(builder: (context, modalSetState) {
          modalSetStateCallback = modalSetState;
          return Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
            child: Material(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Scaffold(
                body: UsersBloc(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildTextInputSection(modalSetState),
                      ),
                      Expanded(

                        child: UserListView(

                          selectedUsers: {},
                          onUserTap: (user, _) async {
                            _searchController!.clear();

                            await channel.addMembers([user.id]);
                            Navigator.pop(context);
                            setState(() {});
                          },
                          crossAxisCount: 2,

                          limit: 20,

                          filter: Filter.and(
                            [
                              // Logic to filter on basis of search query(name, organisation code, not a member)
                              if (_searchController!.text.isNotEmpty)
                                Filter.autoComplete('name', _userNameQuery),
                              Filter.equal('orgCode', globals.organisationCode),
                              Filter.notIn('id', [
                                StreamChat.of(context).currentUser!.id,
                                ...channel.state!.members
                                    .map<String?>(((e) => e.userId))
                                    .whereType<String>(),
                              ]),
                            ],
                          ),
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
                                      const AlwaysScrollableScrollPhysics(),
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
                                              color: StreamChatTheme.of(context)
                                                  .colorTheme
                                                  .textLowEmphasis,
                                            ),
                                          ),
                                          Text(
                                              'No user matches these keywords...'),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildTextInputSection(modalSetState) {
    final theme = StreamChatTheme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                height: 36,
                child: TextField(
                  controller: _searchController,
                  cursorColor: theme.colorTheme.textHighEmphasis,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: theme.textTheme.body.copyWith(
                      color: theme.colorTheme.textLowEmphasis,
                    ),
                    prefixIconConstraints: BoxConstraints.tight(Size(40, 24)),
                    prefixIcon: StreamSvgIcon.search(
                      color: theme.colorTheme.textHighEmphasis,
                      size: 24,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide(
                        color: theme.colorTheme.borders,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: theme.colorTheme.borders,
                        )),
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            IconButton(
              icon: StreamSvgIcon.closeSmall(
                color: theme.colorTheme.textHighEmphasis,
              ),
              constraints: BoxConstraints.tightFor(
                height: 24,
                width: 24,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 24,
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ],
    );
  }
  /// builds widget to show member info in a group on group info page
  void _showUserInfoModal(User? user, bool isUserAdmin) {
    var channel = StreamChannel.of(context).channel;
    final color = StreamChatTheme.of(context).colorTheme.barsBg;

    showModalBottomSheet(
      useRootNavigator: false,
      context: context,
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      backgroundColor: color,
      builder: (context) {
        return SafeArea(
          child: StreamChannel(
            channel: channel,
            child: Material(
              color: color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24.0,
                  ),
                  Center(
                    child: Text(
                      user!.name,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  _buildConnectedTitleState(user)!,
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: UserAvatar(
                        user: user,
                        constraints: BoxConstraints(
                          maxHeight: 64.0,
                          minHeight: 64.0,
                        ),
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                  if (StreamChat.of(context).currentUser!.id != user.id)
                    _buildModalListTile(
                      context,
                      StreamSvgIcon.user(
                        color: appLightColor,
                        size: 20.0,
                      ),
                      'View info',
                      () async {
                        var client = StreamChat.of(context).client;

                        var c = client.channel('messaging', extraData: {
                          'members': [
                            user.id,
                            StreamChat.of(context).currentUser!.id,
                          ],
                        });

                        await c.watch();

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StreamChannel(
                              channel: c,
                              child: ChatInfoPage(
                                messageTheme: widget.messageTheme,
                                user: user,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (StreamChat.of(context).currentUser!.id != user.id)
                    _buildModalListTile(
                      context,
                      StreamSvgIcon.message(
                        color: appLightColor,
                        size: 24.0,
                      ),
                      'Message',
                      () async {
                        var client = StreamChat.of(context).client;

                        var c = client.channel('messaging', extraData: {
                          'members': [
                            user.id,
                            StreamChat.of(context).currentUser!.id,
                          ],
                        });

                        await c.watch();

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StreamChannel(
                              channel: c,
                              child: ChannelPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  if (!channel.isDistinct &&
                      StreamChat.of(context).currentUser!.id != user.id &&
                      isUserAdmin)
                    _buildModalListTile(
                        context,
                        StreamSvgIcon.userRemove(
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .accentError,
                          size: 24.0,
                        ),
                        'Remove From Group', () async {
                      // Remove members of the group
                      final res = await showConfirmationDialog(
                        context,
                        title: 'Remove member',
                        okText: 'REMOVE',
                        question:
                            'Are you sure you want to remove this member?',
                        cancelText: 'CANCEL',
                      );

                      if (res == true) {
                        await channel.removeMembers([user.id]);
                      }
                      Navigator.pop(context);
                    },
                        color:
                            StreamChatTheme.of(context).colorTheme.accentError),
                  _buildModalListTile(
                      context,
                      StreamSvgIcon.closeSmall(
                        color: appLightColor,
                        size: 24.0,
                      ),
                      'Cancel', () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
    );
  }
  /// displays the info whether user is online or not
  Widget? _buildConnectedTitleState(User? user) {
    var alternativeWidget;

    final otherMember = user;

    if (otherMember != null) {
      if (otherMember.online) {
        alternativeWidget = Text(
          'Online',
          style: TextStyle(
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.5)),
        );
      } else {
        alternativeWidget = Text(
          'Last seen ${Jiffy(otherMember.lastActive).fromNow()}',
          style: TextStyle(
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.5)),
        );
      }
    }

    return alternativeWidget;
  }
  /// widget for modal list
  Widget _buildModalListTile(
      BuildContext context, Widget leading, String title, VoidCallback onTap,
      {Color? color}) {
    color ??= StreamChatTheme.of(context).colorTheme.textHighEmphasis;

    return Material(
      color: StreamChatTheme.of(context).colorTheme.barsBg,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 1.0,
              color: StreamChatTheme.of(context).colorTheme.disabled,
            ),
            Container(
              height: 64.0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: leading,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getChannelName(
    double width, {
    List<Member>? members,
    required Map extraData,
    double? maxFontSize,
  }) {
    String? title;
    var client = StreamChat.of(context);
    if (extraData['name'] == null) {
      final otherMembers =
          members!.where((member) => member.user!.id != client.currentUser!.id);
      if (otherMembers.isNotEmpty) {
        final maxWidth = width;
        final maxChars = maxWidth / maxFontSize!;
        var currentChars = 0;
        final currentMembers = <Member>[];
        otherMembers.forEach((element) {
          final newLength = currentChars + element.user!.name.length;
          if (newLength < maxChars) {
            currentChars = newLength;
            currentMembers.add(element);
          }
        });

        final exceedingMembers = otherMembers.length - currentMembers.length;
        title =
            '${currentMembers.map((e) => e.user!.name).join(', ')} ${exceedingMembers > 0 ? '+ $exceedingMembers' : ''}';
      } else {
        title = 'No title';
      }
    } else {
      title = extraData['name'];
    }
    return title;
  }

  String _getLastSeen(User user) {
    // gets the last seen status
    if (user.online) {
      return 'Online';
    } else {
      return 'Last seen ${Jiffy(user.lastActive).fromNow()}';
    }
  }
}

class LeaveOptionTile extends StatelessWidget {
  const LeaveOptionTile({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return OptionListTile(
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      separatorColor: StreamChatTheme.of(context).colorTheme.disabled,
      title: 'Leave Group',
      titleTextStyle: StreamChatTheme.of(context).textTheme.body,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: StreamSvgIcon.userRemove(
          size: 24.0,
          color: StreamChatTheme.of(context)
              .colorTheme
              .accentError
              .withOpacity(0.5),
        ),
      ),
      trailing: Container(
        height: 24.0,
        width: 24.0,
      ),
      onTap: () async {
        final res = await showConfirmationDialog(
          context,
          title: 'Leave conversation',
          okText: 'LEAVE',
          question: 'Are you sure you want to leave this conversation?',
          cancelText: 'CANCEL',
          icon: StreamSvgIcon.userRemove(
            color: appAccentIconColor,
          ),
        );
        if (res == true) {
          final channel = StreamChannel.of(context).channel;
          await channel.removeMembers([StreamChat.of(context).currentUser!.id]);
          Navigator.pop(context);
        }
      },
    );
  }
}
