import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:alfaaz/pages/chat/widgets/media_option_tile.dart';
import 'package:alfaaz/pages/chat/widgets/mute_option_tile.dart';
import 'package:alfaaz/pages/chat/widgets/options_tile.dart';
import 'package:alfaaz/pages/chat/widgets/pin_option_tile.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Detail screen for a 1:1 chat correspondence
class ChatInfoPage extends StatefulWidget {
  final User? user;

  final MessageThemeData messageTheme;

  const ChatInfoPage({
    Key? key,
    required this.messageTheme,
    this.user,
  }) : super(key: key);

  @override
  _ChatInfoPageState createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  ValueNotifier<bool?> mutedBool = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    mutedBool = ValueNotifier(StreamChannel.of(context).channel.isMuted);
  }

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      body: ListView(
        children: [
          _buildUserHeader(), // User Header
          _buildOptionListTiles(), // Options Tiles in the
          Container(
            height: 8.0,
            color: StreamChatTheme.of(context).colorTheme.disabled,
          ),
          // Condition to allow deletion only if the user is an admin
          if ([
            'admin',
            'owner',
          ].contains(channel.state!.members
              .firstWhereOrNull(
                  (m) => m.userId == channel.client.state.currentUser!.id)
              ?.role))
            _buildDeleteListTile(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    print("ahbd");
    print(widget.user);
    return Material(
      color: appAccentIconColor,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  // User Avatar to reder images in a circular container
                  child: UserAvatar(
                    user: widget.user!,
                    constraints: BoxConstraints(
                      maxWidth: 72.0,
                      maxHeight: 72.0,
                    ),
                    borderRadius: BorderRadius.circular(36.0),
                    showOnlineStatus: true,
                  ),
                ),
                Text(
                  widget.user!.name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 7.0),
                _buildConnectedTitleState(),
                SizedBox(height: 15.0),
                OptionListTile(
                  title: '@${widget.user!.id}',
                  tileColor: StreamChatTheme.of(context).colorTheme.appBg,
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      widget.user!.name,
                      style: TextStyle(
                          color: StreamChatTheme.of(context)
                              .colorTheme
                              .textHighEmphasis
                              .withOpacity(0.8),
                          fontSize: 16.0),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              width: 58,
              child: StreamBackButton(),
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
                text: 'Mute User',
                trailingWidget: snapshot.data == null
                    ? CircularProgressIndicator(
                  color: appAccentColor,
                )
                    : ValueListenableBuilder<bool?>(
                  valueListenable: mutedBool,
                  builder: (context, value, _) {
                    return CupertinoSwitch(
                      // Sliding switch
                      activeColor: appAccentColor,
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
            }),
        PinOptionTile(context: context, chatWidget: widget),
        MediaOptionsTile(
          context: context,
          chatWidget: widget,
        ),
        FilesOptionTile(context: context),
        SharedOptionsTile(context: context,widget: widget),
      ],
    );
  }

  Widget _buildDeleteListTile() {
    return OptionListTile(
      title: 'Delete Conversation',
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      titleTextStyle: StreamChatTheme.of(context).textTheme.body.copyWith(
        color: StreamChatTheme.of(context).colorTheme.accentError,
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: StreamSvgIcon.delete(
          color: StreamChatTheme.of(context).colorTheme.accentError,
          size: 24.0,
        ),
      ),
      onTap: () {
        _showDeleteDialog();
      },
      titleColor: StreamChatTheme.of(context).colorTheme.accentError,
    );
  }

  void _showDeleteDialog() async {
    final res = await showConfirmationDialog(
      context,
      title: 'Delete Conversation',
      okText: 'DELETE',
      question: 'Are you sure you want to delete this conversation?',
      cancelText: 'CANCEL',
      icon: StreamSvgIcon.delete(
        color: StreamChatTheme.of(context).colorTheme.accentError,
      ),
    );
    var channel = StreamChannel.of(context).channel;
    if (res == true) {
      await channel.delete().then((value) {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  Widget _buildConnectedTitleState() {
    var alternativeWidget;

    final otherMember = widget.user;

    if (otherMember != null) {
      if (otherMember.online) {
        alternativeWidget = Text(
          'Online',
          style: TextStyle(
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.8)),
        );
      } else {
        alternativeWidget = Text(
          'Last seen ${Jiffy(otherMember.lastActive).fromNow()}',
          style: TextStyle(
              color: StreamChatTheme.of(context)
                  .colorTheme
                  .textHighEmphasis
                  .withOpacity(0.8)),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.user!.online)
          Material(
            type: MaterialType.circle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              constraints: BoxConstraints.tightFor(
                width: 24,
                height: 12,
              ),
              child: Material(
                shape: CircleBorder(),
                color: StreamChatTheme.of(context).colorTheme.accentInfo,
              ),
            ),
            color: StreamChatTheme.of(context).colorTheme.barsBg,
          ),
        alternativeWidget,
        if (widget.user!.online)
          const SizedBox(
            width: 24.0,
          ),
      ],
    );
  }
}

class SharedOptionsTile extends StatelessWidget {
  const SharedOptionsTile({
    Key? key,
    required this.context,
    required this.widget,
  }) : super(key: key);

  final BuildContext context;
  final ChatInfoPage widget;

  @override
  Widget build(BuildContext context) {
    return OptionListTile(
      title: 'Shared groups',
      tileColor: StreamChatTheme.of(context).colorTheme.appBg,
      titleTextStyle: StreamChatTheme.of(context).textTheme.body,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: StreamSvgIcon.iconGroup(
          size: 24.0,
          color: appAccentIconColor,
        ),
      ),
      trailing: StreamSvgIcon.right(
          color: StreamChatTheme.of(context)
              .colorTheme
              .textHighEmphasis
              .withOpacity(0.5)),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => _SharedGroupsScreen(
                    StreamChat.of(context).currentUser, widget.user)));
      },
    );
  }
}

class _SharedGroupsScreen extends StatefulWidget {
  final User? mainUser;
  final User? otherUser;

  const _SharedGroupsScreen(this.mainUser, this.otherUser);

  @override
  __SharedGroupsScreenState createState() => __SharedGroupsScreenState();
}

class __SharedGroupsScreenState extends State<_SharedGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    var chat = StreamChat.of(context);

    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        //brightness: Theme.of(context).brightness,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Shared Groups',
          style: TextStyle(
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
              fontSize: 16.0),
        ),
        leading: const StreamBackButton(),
        backgroundColor: appBlueColor,
      ),
      body: StreamBuilder<List<Channel>>(
        /*
          * Creates a new StreamBuilder that builds itself based on the latest
          * snapshot of interaction with the specified stream and whose
          * build strategy is given by builder.
          * */
        stream: chat.client.queryChannels(
          filter: Filter.and([
            Filter.in_('members', [widget.otherUser!.id]),
            Filter.in_('members', [widget.mainUser!.id]),
          ]),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: appAccentColor,
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamSvgIcon.message(
                    size: 136.0,
                    color: appAccentIconColor,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No Shared Groups',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Group shared with User will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: appLightColor,
                    ),
                  ),
                ],
              ),
            );
          }

          final channels = snapshot.data!
              .where((c) =>
          c.state!.members.any((m) =>
          m.userId != widget.mainUser!.id &&
              m.userId != widget.otherUser!.id) ||
              !c.isDistinct)
              .toList();

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, position) {
              return StreamChannel(
                channel: channels[position],
                child: _buildListTile(channels[position]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListTile(Channel channel) {
    var extraData = channel.extraData;
    var members = channel.state!.members;

    var textStyle = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold);

    return Container(
      height: 64.0,
      child: LayoutBuilder(builder: (context, constraints) {
        String? title;
        if (extraData['name'] == null) {
          final otherMembers = members.where(
                  (member) => member.userId != StreamChat.of(context).currentUser!.id);
          if (otherMembers.isNotEmpty) {
            final maxWidth = constraints.maxWidth;
            final maxChars = maxWidth / textStyle.fontSize!;
            var currentChars = 0;
            final currentMembers = <Member>[];
            otherMembers.forEach((element) {
              final newLength = currentChars + element.user!.name.length;
              if (newLength < maxChars) {
                currentChars = newLength;
                currentMembers.add(element);
              }
            });

            final exceedingMembers =
                otherMembers.length - currentMembers.length;
            title =
            '${currentMembers.map((e) => e.user!.name).join(', ')} ${exceedingMembers > 0 ? '+ $exceedingMembers' : ''}';
          } else {
            title = 'No title';
          }
        } else {
          title = extraData['name'] as String;
        }

        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChannelAvatar(
                      channel: channel,
                      constraints:
                      BoxConstraints(maxWidth: 40.0, maxHeight: 40.0),
                    ),
                  ),
                  Expanded(
                      child: Text(
                        title,
                        style: textStyle,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${channel.memberCount} members',
                      style: TextStyle(
                        color: appAccentIconColor,
                        fontSize: 12.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 1.0,
              color:
              StreamChatTheme.of(context).colorTheme.textHighEmphasis.withOpacity(.08),
            ),
          ],
        );
      }),
    );
  }
}