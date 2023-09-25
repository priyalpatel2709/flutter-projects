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
