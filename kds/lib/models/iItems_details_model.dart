class ItemsDetails {
  int? id;
  int? kdsId;
  String? orderId;
  String? itemId;
  String? itemName;
  String? ordertitle;
  String? ordertype;
  int? qty;
  String? modifiers;
  String? orderNote;
  String? createdOn;
  int? storeId;
  bool? isQueue;
  bool? isInprogress;
  String? inprogressOn;
  bool? isDone;
  bool? isComplete;
  String? doneOn;
  bool? isCancel;
  // bool? isCompleted;
  String? completedOn;
  String? createdBy;
  String? tableName;
  String? dPartner;
  String? displayOrdertype;
  bool? isDelivered;
  String? deliveredOn;
  bool? isReadyToPickup;
  String? readyToPickupOn;

  ItemsDetails({
    this.id,
    this.kdsId,
    this.orderId,
    this.itemId,
    this.itemName,
    this.ordertitle,
    this.ordertype,
    this.qty,
    this.modifiers,
    this.orderNote,
    this.createdOn,
    this.storeId,
    this.isQueue,
    this.isInprogress,
    this.inprogressOn,
    this.isDone,
    this.doneOn,
    this.isCancel,
    // this.isCompleted,
    this.completedOn,
    this.createdBy,
    this.tableName,
    this.dPartner,
    this.displayOrdertype,
    this.isComplete,
    this.deliveredOn,
    this.isDelivered,
    this.isReadyToPickup,
    this.readyToPickupOn,
  });

  ItemsDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kdsId = json['kdsId'];
    orderId = json['orderId'];
    itemId = json['itemId'];
    itemName = json['itemName'];
    ordertitle = json['ordertitle'];
    ordertype = json['ordertype'];
    qty = json['quantity'];
    modifiers = json['modifiers'];
    orderNote = json['orderNote'];
    createdOn = json['createdOn'];
    storeId = json['storeId'];
    isQueue = json['isQueue'];
    isInprogress = json['isInprogress'];
    inprogressOn = json['inprogressOn'];
    isDone = json['isDone'];
    doneOn = json['doneOn'];
    isCancel = json['isCancelled'];
    // isCompleted = json['isCompleted'];
    completedOn = json['completedOn'];
    createdBy = json['createdBy'];
    tableName = json['tableName'];
    dPartner = json['deliveryPartner'];
    displayOrdertype = json['displayOrdertype'];
    isComplete = json['isCompleted'];
    deliveredOn = json['deliveredOn'];
    isDelivered = json['isDelivered'];
    isReadyToPickup = json['isReadyToPickup'];
    readyToPickupOn = json['readyToPickupOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kdsId'] = kdsId;
    data['orderId'] = orderId;
    data['itemId'] = itemId;
    data['itemName'] = itemName;
    data['ordertitle'] = ordertitle;
    data['ordertype'] = ordertype;
    data['quantity'] = qty;
    data['modifiers'] = modifiers;
    data['orderNote'] = orderNote;
    data['createdOn'] = createdOn;
    data['storeId'] = storeId;
    data['isQueue'] = isQueue;
    data['isInprogress'] = isInprogress;
    data['inprogressOn'] = inprogressOn;
    data['isDone'] = isDone;
    data['doneOn'] = doneOn;
    data['isCancelled'] = isCancel;
    // data['isCompleted'] = isCompleted;
    data['completedOn'] = completedOn;
    data['createdBy'] = createdBy;
    data['tableName'] = tableName;
    data['deliveryPartner'] = dPartner;
    data['displayOrdertype'] = displayOrdertype;
    data['isCompleted'] = isComplete;
    data['readyToPickupOn'] = readyToPickupOn;
    data['isReadyToPickup'] = isReadyToPickup;
    data['deliveredOn'] = deliveredOn;
    data['isDelivered'] = isDelivered;
    return data;
  }
}
