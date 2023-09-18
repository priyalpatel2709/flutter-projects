// ignore_for_file: prefer_const_constructors,

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message_lisiview extends StatelessWidget {
  // final CrossAxisAlignment alignment;
  // final bool containsUrl;
  // final Color colors;
  // final bool right;
  // final bool left;
  final String content;
  final bool isGroupChat;
  final String senderName;
  final String createdAt;
  final String storedUserId;
  final String chatSenderId;
  Message_lisiview({
    //required this.alignment,
    // required this.containsUrl,
    // required this.colors,
    // required this.right,
    // required this.left,
    required this.content,
    required this.isGroupChat,
    required this.senderName,
    required this.createdAt,
    required this.storedUserId,
    required this.chatSenderId,
  });

  String formatTime(DateTime dateTime) {
    final timeFormat = DateFormat.jm('en_IN'); // Add date and time format
    final indianTime = dateTime.toLocal(); // Convert to local time zone (IST)
    return timeFormat.format(indianTime);
  }

  String messageTime(utcdateTime) {
    String utcTimestamp = utcdateTime;
    DateTime dateTime = DateTime.parse(utcTimestamp);
    String formattedTime = formatTime(dateTime);
    return formattedTime; // Output: 10:47 AM
  }

  @override
  Widget build(BuildContext context) {
    bool containsUrl = content
        .toString()
        .contains("http://res.cloudinary.com/dtzrtlyuu/image/upload/");
    CrossAxisAlignment alignment;
    bool right;
    bool left;
    Color colors;
    if (chatSenderId == storedUserId) {
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

    return ListTile(
      title: Column(
        crossAxisAlignment: alignment,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: containsUrl
                ? BoxDecoration(
                    color: colors,
                    borderRadius: BorderRadius.only(
                        topRight: right
                            ? Radius.circular(0.0)
                            : Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        topLeft:
                            left ? Radius.circular(0.0) : Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0)),
                  )
                : BoxDecoration(
                    color: colors,
                    borderRadius: BorderRadius.only(
                        topRight: right
                            ? Radius.circular(0.0)
                            : Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                        topLeft:
                            left ? Radius.circular(0.0) : Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0)),
                  ),
            child: containsUrl
                ? InkWell(
                    onDoubleTap: () {
                      // deleteMsg(chatMessage.sender.id, chatMessage.id);
                    },
                    child: Image.network(content))
                : InkWell(
                    onDoubleTap: () {
                      // deleteMsg(chatMessage.sender.id, chatMessage.id);
                    },
                    child: !isGroupChat
                        ? RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: content,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${messageTime(createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
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
                                        text: '~ $senderName',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ))),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: content,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${messageTime(createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
