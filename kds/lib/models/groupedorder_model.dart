class GroupedOrder {
  final int id;
  final int kdsId;
  final String orderId;
  final String orderTitle;
  final String orderType;
  final String orderNote;
  final String createdOn;
  final int storeId;
  String? tableName;
  String? dPartner;
  final String displayOrderType;
  final bool isDelivered;
  final String? deliveredOn;
  final bool isReadyToPickup;
  String? readyToPickupOn;
  late final List<OrderItemModel> items;

  // New fields
  final bool isAllInProgress;
  final bool isAllDone;
  final bool isAnyDone;
  final bool isAllCancel;
  final bool isAnyInProgress;
  // final bool isAnyComplete;
  // final bool isAllComplete;
  final bool isNewOrder;
  final bool isDineIn;
  final bool isAllDelivered;
  final bool isAnyDelivered;

  GroupedOrder({
    required this.id,
    this.kdsId = 0,
    required this.orderId,
    required this.orderTitle,
    required this.orderType,
    required this.orderNote,
    required this.createdOn,
    required this.storeId,
    this.tableName,
    this.dPartner,
    required this.displayOrderType,
    required this.items,
    required this.isAllInProgress,
    required this.isAllDone,
    required this.isAllCancel,
    required this.isAnyInProgress,
    required this.isAnyDone,
    // required this.isAnyComplete,
    // required this.isAllComplete,
    required this.isNewOrder,
    required this.isDineIn,
    this.deliveredOn,
    required this.isAllDelivered,
    required this.isAnyDelivered,
    required this.isDelivered,
    required this.isReadyToPickup,
    this.readyToPickupOn,
  });

  factory GroupedOrder.fromJson(Map<String, dynamic> json) {
    return GroupedOrder(
      id: json['id'],
      // kdsId: json['kdsId'] ?? 0,
      orderId: json['orderId'],
      orderTitle: json['orderTitle'],
      orderType: json['orderType'],
      orderNote: json['orderNote'],
      createdOn: json['createdOn'],
      storeId: json['storeId'],
      tableName: json['tableName'] ?? '',
      dPartner: json['deliveryPartner'] ?? '',
      displayOrderType: json['displayOrderType'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      isAllInProgress: json['isAllInProgress'] ?? false,
      isAllDone: json['isAllDone'] ?? false,
      isAllCancel: json['isAllCancel'] ?? false,
      isAnyInProgress: json['isAnyInProgress'] ?? false,
      isAnyDone: json['isAnyDone'] ?? false,
      // isAnyComplete: json['isAllComplete'],
      // isAllComplete: json['isAnyComplete'],
      isNewOrder: json['isNewOrder'] ?? false,
      isDineIn: json['isDineIn'] ?? false,
      deliveredOn: json['deliveredOn'] ?? '',
      isAllDelivered: json['isAllDelivered'] ?? false,
      isAnyDelivered: json['isAnyDelivered'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      isReadyToPickup: json['isReadyToPickup'] ?? false,
      readyToPickupOn: json['readyToPickupOn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kdsId': kdsId,
      'orderId': orderId,
      'orderTitle': orderTitle,
      'orderType': orderType,
      'orderNote': orderNote,
      'createdOn': createdOn,
      'storeId': storeId,
      'tableName': tableName,
      'deliveryPartner': dPartner,
      'displayOrderType': displayOrderType,
      'items': items.map((item) => item.toJson()).toList(),
      'isAllInProgress': isAllInProgress,
      'isAllDone': isAllDone,
      'isAllCancel': isAllCancel,
      'isAnyInProgress': isAnyInProgress,
      'isAnyDone': isAnyDone,
      'isNewOrder': isNewOrder,
      'isDineIn': isDineIn,
      'deliveredOn': deliveredOn,
      'isAllDelivered': isAllDelivered,
      'isAnyDelivered': isAnyDelivered,
      'isDelivered': isDelivered,
      'isReadyToPickup': isReadyToPickup,
      'readyToPickupOn': readyToPickupOn,
    };
  }
}

class OrderItemModel {
  final String itemId;
  final String itemName;
  final int qty;
  final String modifiers;
  final bool isInProgress;
  final bool isDone;
  final bool isCancel;
  // final bool isComplete;
  final int kdsId;
  final bool isDelivered;
  final String deliveredOn;
  final bool isReadyToPickup;
  final String readyToPickupOn;

  OrderItemModel({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.modifiers,
    required this.isInProgress,
    required this.isDone,
    required this.isCancel,
    required this.kdsId,
    // required this.isComplete,
    required this.isDelivered,
    required this.deliveredOn,
    required this.isReadyToPickup,
    this.readyToPickupOn = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      itemId: json['itemId'],
      itemName: json['itemName'],
      qty: json['quantity'],
      modifiers: json['modifiers'],
      isInProgress: json['isInprogress'],
      isDone: json['isDone'],
      isCancel: json['isCancelled'],
      kdsId: json['kdsId'],
      // isComplete: json['isCompleted'],
      isDelivered: json['isDelivered'],
      deliveredOn: json['deliveredOn'] ?? '',
      isReadyToPickup: json['isReadyToPickup'],
      readyToPickupOn: json['readyToPickupOn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': qty,
      'modifiers': modifiers,
      'isInprogress': isInProgress,
      'isDone': isDone,
      'isCancelled': isCancel,
      'kdsId': kdsId,
      // 'isCompleted': isComplete,
      'readyToPickupOn': readyToPickupOn,
      'isReadyToPickup': isReadyToPickup,
      'deliveredOn': deliveredOn,
      'isDelivered': isDelivered,
    };
  }
}
