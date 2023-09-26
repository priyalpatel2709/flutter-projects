import 'package:aapni_vato/widgets/todaydate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message_lisiview extends StatelessWidget {
  final VoidCallback onDeleteMes;
  final String content;
  final bool isGroupChat;
  final String senderName;
  final String createdAt;
  final String storedUserId;
  final String chatSenderId;
  final temp;
  final int index;

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
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    bool containsUrl = content
        .toString()
        .contains("http://res.cloudinary.com/dtzrtlyuu/image/upload/");
    CrossAxisAlignment alignment;
    bool right;
    bool left;
    Color colors;
    bool isSameSender = chatSenderId == storedUserId;
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
    String dateOnly = getDateOnly(createdAt);

    return Column(
      children: [
        Today(
          i: index,
          mCreatedAtDate: dateOnly,
          temp: temp,
        ),
        ListTile(
          key: key,
          title: Column(
            crossAxisAlignment: alignment,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                padding: const EdgeInsets.all(8),
                decoration: containsUrl
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
                            bottomLeft: const Radius.circular(20.0)),
                      )
                    : BoxDecoration(
                        color: colors,
                        borderRadius: BorderRadius.only(
                            topRight: right
                                ? const Radius.circular(0.0)
                                : const Radius.circular(40.0),
                            bottomRight: const Radius.circular(40.0),
                            topLeft: left
                                ? const Radius.circular(0.0)
                                : const Radius.circular(40.0),
                            bottomLeft: const Radius.circular(40.0)),
                      ),
                child: containsUrl
                    ? InkWell(
                        onDoubleTap: onDeleteMes,
                        child: Image.network(content),
                      )
                    : InkWell(
                        onDoubleTap: onDeleteMes,
                        child: !isGroupChat
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: content,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ${messageTime(createdAt)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSameSender)
                                    const Icon(
                                      Icons.check,
                                      size: 18,
                                    )
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!right)
                                    RichText(
                                      text: TextSpan(
                                        text: '~ $senderName',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: content,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ${messageTime(createdAt)}',
                                          style: const TextStyle(
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
        ),
      ],
    );
  }
}
