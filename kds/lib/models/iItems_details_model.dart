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
  bool? isDone;
  bool? isCancel;
  Null? createdBy;
  String? tableName;
  String? dPartner;
  String? displayOrdertype;

  ItemsDetails(
      {this.id,
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
      this.isDone,
      this.isCancel,
      this.createdBy,
      this.tableName,
      this.dPartner,
      this.displayOrdertype});

  ItemsDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kdsId = json['kdsId'];
    orderId = json['orderId'];
    itemId = json['itemId'];
    itemName = json['itemName'];
    ordertitle = json['ordertitle'];
    ordertype = json['ordertype'];
    qty = json['qty'];
    modifiers = json['modifiers'];
    orderNote = json['orderNote'];
    createdOn = json['createdOn'];
    storeId = json['storeId'];
    isQueue = json['isQueue'];
    isInprogress = json['isInprogress'];
    isDone = json['isDone'];
    isCancel = json['isCancel'];
    createdBy = json['createdBy'];
    tableName = json['tableName'];
    dPartner = json['dPartner'];
    displayOrdertype = json['displayOrdertype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['kdsId'] = this.kdsId;
    data['orderId'] = this.orderId;
    data['itemId'] = this.itemId;
    data['itemName'] = this.itemName;
    data['ordertitle'] = this.ordertitle;
    data['ordertype'] = this.ordertype;
    data['qty'] = this.qty;
    data['modifiers'] = this.modifiers;
    data['orderNote'] = this.orderNote;
    data['createdOn'] = this.createdOn;
    data['storeId'] = this.storeId;
    data['isQueue'] = this.isQueue;
    data['isInprogress'] = this.isInprogress;
    data['isDone'] = this.isDone;
    data['isCancel'] = this.isCancel;
    data['createdBy'] = this.createdBy;
    data['tableName'] = this.tableName;
    data['dPartner'] = this.dPartner;
    data['displayOrdertype'] = this.displayOrdertype;
    return data;
  }
}
