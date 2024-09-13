class GroupedOrder {
  final int id;
  final int kdsId;
  final String orderId;
  final String orderTitle;
  final String orderType;
  final String orderNote;
  final String createdOn;
  final int storeId;
  final String tableName;
  final String dPartner;
  final String displayOrderType;
  final List<OrderItem> items;

  // New fields
  final bool isAllInProgress;
  final bool isAllDone;
  final bool isAllCancel;

  GroupedOrder({
    required this.id,
    required this.kdsId,
    required this.orderId,
    required this.orderTitle,
    required this.orderType,
    required this.orderNote,
    required this.createdOn,
    required this.storeId,
    required this.tableName,
    required this.dPartner,
    required this.displayOrderType,
    required this.items,
    required this.isAllInProgress,
    required this.isAllDone,
    required this.isAllCancel,
  });
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int qty;
  final String modifiers;
  final bool isQueue;
  final bool isInprogress;
  final bool isDone;
  final bool isCancel;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.modifiers,
    required this.isQueue,
    required this.isInprogress,
    required this.isDone,
    required this.isCancel,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'],
      itemName: json['itemName'],
      qty: json['qty'],
      modifiers: json['modifiers'],
      isQueue: json['isQueue'],
      isInprogress: json['isInprogress'],
      isDone: json['isDone'],
      isCancel: json['isCancel'],
    );
  }
}
