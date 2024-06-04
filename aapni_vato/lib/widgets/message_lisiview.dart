import 'package:aapni_vato/widgets/todaydate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilits/miscellaneous.dart';

class Message_lisiview extends StatefulWidget {
  final VoidCallback onDeleteMes;
  final VoidCallback onTap;
  final String content;
  final bool isGroupChat;
  final String senderName;
  final String createdAt;
  final String storedUserId;
  final String chatSenderId;
  final temp;
  final int index;
  final String status;

  // Constructor
  Message_lisiview({
    Key? key,
    required this.content,
    required this.isGroupChat,
    required this.senderName,
    required this.createdAt,
    required this.storedUserId,
    required this.chatSenderId,
    required this.onDeleteMes,
    required this.index,
    this.temp,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  State<Message_lisiview> createState() => _Message_lisiviewState();
}

class _Message_lisiviewState extends State<Message_lisiview> {
  // Method to format time
  String formatTime(DateTime dateTime) {
    final timeFormat = DateFormat.jm('en_IN'); // Add date and time format
    final indianTime = dateTime.toLocal(); // Convert to local time zone (IST)
    return timeFormat.format(indianTime);
  }

  // Method to extract date
  String getDateOnly(String dateTimeString) {
    return dateTimeString.substring(0, 10);
  }

  // Method to get message time
  String messageTime(String utcdateTime) {
    String utcTimestamp = utcdateTime;
    DateTime dateTime = DateTime.parse(utcTimestamp);
    return formatTime(dateTime); // Output: 10:47 AM
  }

  bool showFullText = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool containsImageUrl = widget.content
        .toString()
        .contains("http://res.cloudinary.com/dtzrtlyuu/image/upload/");

    bool containsUrl = widget.content.toString().contains("http");
    CrossAxisAlignment alignment;
    bool right;
    bool left;
    Color colors;
    bool isSameSender = widget.chatSenderId == widget.storedUserId;
    if (isSameSender) {
      alignment = CrossAxisAlignment.end;
      right = true;
      left = false;
      colors = const Color.fromARGB(255, 190, 227, 248);
    } else {
      alignment = CrossAxisAlignment.start;
      colors = const Color.fromARGB(255, 185, 245, 208);
      right = false;
      left = true;
    }

    // Get the date from createdAt
    String dateOnly = getDateOnly(widget.createdAt);

    return Column(
      children: [
        Today(
          i: widget.index,
          mCreatedAtDate: dateOnly,
          temp: widget.temp,
        ),
        ListTile(
          // key: key,
          title: Column(
            crossAxisAlignment: alignment,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                padding: const EdgeInsets.all(8),
                decoration: containsImageUrl
                    ? BoxDecoration(
                        color: colors,
                        borderRadius: BorderRadius.only(
                          topRight: right
                              ? const Radius.circular(0.0)
                              : const Radius.circular(20.0),
                          bottomRight: const Radius.circular(20.0),
                          topLeft: left
                              ? const Radius.circular(0.0)
                              : const Radius.circular(20.0),
                          bottomLeft: const Radius.circular(20.0),
                        ),
                      )
                    : BoxDecoration(
                        color: colors,
                        borderRadius: BorderRadius.only(
                          topRight: right
                              ? const Radius.circular(0.0)
                              : const Radius.circular(20.0),
                          bottomRight: const Radius.circular(20.0),
                          topLeft: left
                              ? const Radius.circular(0.0)
                              : const Radius.circular(20.0),
                          bottomLeft: const Radius.circular(20.0),
                        ),
                      ),
                child: containsImageUrl
                    ? InkWell(
                        onDoubleTap: widget.onDeleteMes,
                        child: Image.network(widget.content),
                      )
                    : InkWell(
                        onDoubleTap: widget.onDeleteMes,
                        child: !widget.isGroupChat
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: widget.content,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: containsUrl
                                                  ? Colors.blue
                                                  : Colors.black,
                                              decoration: containsUrl
                                                  ? TextDecoration.underline
                                                  : null,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '   ${messageTime(widget.createdAt)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: showFullText ||
                                              widget.content.length <= 200
                                          ? null
                                          : 10,
                                      onTap: containsUrl
                                          ? () {
                                              launchInBrowser(
                                                  Uri.parse(widget.content));
                                            }
                                          : null,
                                      // showCursor: true, // to show the cursor
                                      // contextMenuBuilder: (context, editableTextState) {

                                      // }, // to show copy option in the toolbar
                                      // overflow: showFullText
                                      //     ? TextOverflow.visible
                                      //     : TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (widget.content.length > 200)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showFullText = !showFullText;
                                          });
                                        },
                                        child: Text(
                                          showFullText
                                              ? 'Show less'
                                              : 'Show more',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!right)
                                    RichText(
                                      text: TextSpan(
                                        text: '~ ${widget.senderName}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.content,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                        softWrap: true,
                                        maxLines: showFullText
                                            ? null
                                            : 10, // Max lines to display initially
                                        overflow: showFullText
                                            ? TextOverflow.visible
                                            : TextOverflow
                                                .ellipsis, // Show ellipsis when exceeding max lines
                                      ),
                                      const SizedBox(height: 4),
                                      if (widget.content.length >
                                          200) // Adjust the length as needed
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showFullText = !showFullText;
                                            });
                                          },
                                          child: Text(
                                            showFullText
                                                ? 'Show less'
                                                : 'Show more',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            messageTime(widget.createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          if (isSameSender)
                                            if (widget.status == 'Offline')
                                              const Icon(
                                                Icons.check,
                                                size: 18,
                                              )
                                            else if (widget.status == 'Inchat')
                                              Image.asset(
                                                'assets/img/double-tick-indicator.png',
                                                height: 20,
                                                color: Colors.blue,
                                              )
                                            else
                                              Image.asset(
                                                'assets/img/double-tick-indicator.png',
                                                height: 20,
                                              ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
