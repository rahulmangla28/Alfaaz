import 'package:flutter/material.dart';
import 'package:alfaaz/config/constants.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/*
This page renders the threads for the messages sent a chat conversation
or a channel discussion
*/

class ThreadPage extends StatefulWidget {
  final Message? parent;
  final int? initialScrollIndex;
  final double? initialAlignment;

  const ThreadPage({
    Key? key,
    this.parent,
    this.initialScrollIndex,
    this.initialAlignment,
  }) : super(key: key);

  @override
  _ThreadPageState createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  Message? _quotedMessage;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _reply(Message message) {
    setState(() => _quotedMessage = message);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlueColor,
      appBar: ThreadHeader(
        parent: widget.parent!,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              parentMessage: widget.parent,
              initialScrollIndex: widget.initialScrollIndex,
              initialAlignment: widget.initialAlignment,
              onMessageSwiped: _reply,
              
              //pinPermissions: const ['owner', 'admin', 'member'],
            ),
              // Expanded(
              //   child: MessageWidget(
              //     onReplyTap: _reply,
              //     messageTheme: StreamChat.of(context)., message: null,
              //   ),
            
          ),
          if (widget.parent!.type != 'deleted')
            MessageInput(
              parentMessage: widget.parent,
              focusNode: _focusNode,
              quotedMessage: _quotedMessage,
              onQuotedMessageCleared: () {
                setState(() => _quotedMessage = null);
                _focusNode.unfocus();
              },
            ),
        ],
      ),
    );
  }
}