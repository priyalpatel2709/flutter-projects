import 'package:url_launcher/url_launcher.dart';

String isSameDate(List<dynamic> messages, int mIndex) {
  final messagesCreatedAtDate =
      (messages[messages.length - 1]['createdAt'] as String).substring(0, 10);
  final mCreatedAtDate =
      (messages[mIndex]['createdAt'] as String).substring(0, 10);

  if (messagesCreatedAtDate == mCreatedAtDate) {
    return mCreatedAtDate;
  } else {
    return mCreatedAtDate;
  }
}

Future<void> launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}
