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

Future<void> launchInBrowserV2(String urlString) async {
  if (await canLaunch(urlString)) {
    await launch(
      urlString,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'header_key': 'header_value'},
    );
  } else {
    throw 'Could not launch $urlString';
  }
}
