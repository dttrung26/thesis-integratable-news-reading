class OrderNote {
  int id;
  String dateCreated;
  String note;

  OrderNote.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    note = json['note'];
  }
}