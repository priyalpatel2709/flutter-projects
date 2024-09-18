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
  String? dPartner;
  final String displayOrderType;
  final List<OrderItem> items;

  // New fields
  final bool isAllInProgress;
  final bool isAllDone;
  final bool isAnyDone;
  final bool isAllCancel;
  final bool isAnyInProgress;

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
    this.dPartner,
    required this.displayOrderType,
    required this.items,
    required this.isAllInProgress,
    required this.isAllDone,
    required this.isAllCancel,
    required this.isAnyInProgress,
    required this.isAnyDone,
  });

  factory GroupedOrder.fromJson(Map<String, dynamic> json) {
    return GroupedOrder(
      id: json['id'],
      kdsId: json['kdsId'],
      orderId: json['orderId'],
      orderTitle: json['ordertitle'],
      orderType: json['ordertype'],
      orderNote: json['orderNote'],
      createdOn: json['createdOn'],
      storeId: json['storeId'],
      tableName: json['tableName'],
      dPartner: json['deliveryPartner'],
      displayOrderType: json['displayOrdertype'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      isAllInProgress: json['isAllInProgress'],
      isAllDone: json['isAllDone'],
      isAllCancel: json['isAllCancel'],
      isAnyInProgress: json['isAnyInProgress'],
      isAnyDone: json['isAnyDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kdsId': kdsId,
      'orderId': orderId,
      'ordertitle': orderTitle,
      'ordertype': orderType,
      'orderNote': orderNote,
      'createdOn': createdOn,
      'storeId': storeId,
      'tableName': tableName,
      'deliveryPartner': dPartner,
      'displayOrdertype': displayOrderType,
      'items': items.map((item) => item.toJson()).toList(),
      'isAllInProgress': isAllInProgress,
      'isAllDone': isAllDone,
      'isAllCancel': isAllCancel,
      'isAnyInProgress': isAnyInProgress,
      'isAnyDone': isAnyDone,
    };
  }
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int qty;
  final String modifiers;
  final bool isInprogress;
  final bool isDone;
  final bool isCancel;
  final int kdsId;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.modifiers,
    required this.isInprogress,
    required this.isDone,
    required this.isCancel,
    required this.kdsId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'],
      itemName: json['itemName'],
      qty: json['quantity'],
      modifiers: json['modifiers'],
      isInprogress: json['isInprogress'],
      isDone: json['isDone'],
      isCancel: json['isCancelled'],
      kdsId: json['kdsId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': qty,
      'modifiers': modifiers,
      'isInprogress': isInprogress,
      'isDone': isDone,
      'isCancelled': isCancel,
      'kdsId': kdsId,
    };
  }
}
