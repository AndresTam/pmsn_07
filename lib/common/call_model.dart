class CallModel {
  String? id,
      senderid,
      receiverid,
      callid,
      receiverName,
      senderName,
      receiverImage,
      senderImage;
  DateTime? created;
  bool? isMade, video;

  CallModel({
    this.video,
    this.callid,
    this.created,
    this.id,
    this.receiverImage,
    this.receiverName,
    this.receiverid,
    this.senderImage,
    this.senderName,
    this.senderid,
    this.isMade,
  });

  factory CallModel.fromMap(var map) {
    return CallModel(
      video: map['video'],
      id: map['id'],
      callid: map['callid'],
      created: map['created'].toDate(),
      receiverImage: map['receiver_image'],
      receiverName: map['receiver_name'],
      receiverid: map['receiver_id'],
      senderImage: map['sender_image'],
      senderName: map['sender_name'],
      senderid: map['sender_id'],
      isMade: map['isMade'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'video': video ?? false,
      'id': id ?? '',
      'callid': callid ?? '',
      'created': created ?? DateTime.now(),
      'receiver_image': receiverImage ?? '',
      'receiver_name': receiverName ?? '',
      'receiver_id': receiverid ?? '',
      'sender_id': senderid ?? '',
      'sender_image': senderImage ?? '',
      'sender_name': senderName ?? '',
      'isMade': isMade ?? false,
    };
  }
}
