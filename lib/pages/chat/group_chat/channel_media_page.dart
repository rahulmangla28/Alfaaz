import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:video_player/video_player.dart';


///This page renders the media Files in a grid form and integrates the BusinessLogic
///with the widgets for the media shared in a channel
///powered by Stream Chat SDK.


class ChannelMediaPage extends StatefulWidget {
  final List<SortOption>? sortOptions;

  final PaginationParams paginationParams;

  final WidgetBuilder? emptyBuilder;

  final ShowMessageCallback? onShowMessage;

  final MessageThemeData messageThemeData;

  const ChannelMediaPage({
    required this.messageThemeData,
    this.sortOptions,
    required this.paginationParams,
    this.emptyBuilder,
    this.onShowMessage,
  });

  @override
  _ChannelMediaPageState createState() => _ChannelMediaPageState();
}

class _ChannelMediaPageState extends State<ChannelMediaPage> {
  Map<String?, VideoPlayerController?> controllerCache = {};

  @override
  void initState() {
    super.initState();
    final messageSearchBloc = MessageSearchBloc.of(context);
    messageSearchBloc.search(

      ///Filters the media attachments with cid
      filter: Filter.in_(
        'cid',
        [StreamChannel.of(context).channel.cid!],
      ),
      messageFilter: Filter.in_(
        'attachments.type',
        const ['image', 'video'],
      ),
      sort: widget.sortOptions,
      pagination: widget.paginationParams,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Photos & Videos',
          style: TextStyle(
            color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
            fontSize: 16.0,
          ),
        ),
        leading: const StreamBackButton(),
        backgroundColor: appBlueColor,
      ),
      body: _buildMediaGrid(),
    );
  }

  Widget _buildMediaGrid() {
    final messageSearchBloc = MessageSearchBloc.of(context);

    return StreamBuilder<List<GetMessageResponse>>(
      /*
          * Creates a new StreamBuilder that builds itself based on the latest
          * snapshot of interaction with the specified stream and whose
          * build strategy is given by builder.
          * */
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: appAccentColor,
            ),
          );
        }

        if (snapshot.data!.isEmpty) {
          if (widget.emptyBuilder != null) {
            return widget.emptyBuilder!(context);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamSvgIcon.pictures(
                  size: 136.0,
                  color: StreamChatTheme.of(context).colorTheme.disabled,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No Media',
                  style: TextStyle(
                    fontSize: 14.0,
                    color:
                        StreamChatTheme.of(context).colorTheme.textHighEmphasis,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Photos or video sent in this chat will \nappear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appAccentIconColor,
                  ),
                ),
              ],
            ),
          );
        }

        final media = <_AssetPackage>[];

        for (var item in snapshot.data!) {
          item.message.attachments
              .where((e) =>
                  (e.type == 'image' || e.type == 'video') &&
                  e.ogScrapeUrl == null)
              .forEach((e) {
            VideoPlayerController? controller;
            if (e.type == 'video') {
              var cachedController = controllerCache[e.assetUrl];

              if (cachedController == null) {
                controller = VideoPlayerController.network(e.assetUrl!);
                controller.initialize();
                controllerCache[e.assetUrl] = controller;
              } else {
                controller = cachedController;
              }
            }
            media.add(_AssetPackage(e, item.message, controller));
          });
        }

        return LazyLoadScrollView(
          onEndOfPage: () => messageSearchBloc.search(
            filter: Filter.in_(
              'cid',
              [StreamChannel.of(context).channel.cid!],
            ),
            messageFilter: Filter.in_(
              'attachments.type',
              const ['image', 'video'],
            ),
            sort: widget.sortOptions,
            pagination: widget.paginationParams.copyWith(
              offset: messageSearchBloc.messageResponses?.length ?? 0,
            ),
          ),
          child: GridView.builder(
            /*
            Builds the media attachments in the form of a builder
            to Create a scrollable, 2D array of widgets
            * */
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemBuilder: (context, position) {
              var channel = StreamChannel.of(context).channel;
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StreamChannel(
                          channel: channel,
                          child: FullScreenMedia(
                            mediaAttachments:
                                media.map((e) => e.attachment).toList(),
                            startIndex: position,
                            message: media[position].message,
                            userName: media[position].message.user!.name,
                            onShowMessage: widget.onShowMessage,
                          ),
                        ),
                      ),
                    );
                  },
                  child: media[position].attachment.type == 'image'
                      ? IgnorePointer(
                          child: ImageAttachment(
                            attachment: media[position].attachment,
                            message: media[position].message,
                            showTitle: false,
                            size: Size(
                              MediaQuery.of(context).size.width * 0.8,
                              MediaQuery.of(context).size.height * 0.3,
                            ),
                            messageTheme: widget.messageThemeData,
                          ),
                        )
                      : VideoPlayer(media[position].videoPlayer!),
                ),
              );
            },
            itemCount: media.length,
          ),
        );
      },
      stream: messageSearchBloc.messagesStream,
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var c in controllerCache.values) {
      c!.dispose();
    }
  }
}

class _AssetPackage {
  Attachment attachment;
  Message message;
  VideoPlayerController? videoPlayer;

  _AssetPackage(this.attachment, this.message, this.videoPlayer);
}
