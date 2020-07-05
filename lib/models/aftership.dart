class AfterShip {
  int count;
  List<Tracking> trackings = [];

  AfterShip.fromJson(Map<String, dynamic> json) {
    count = json['data']['count'];
    for (var i = 0; i < 4; i++) {
      trackings.add(Tracking.fromJson(json['data']['trackings'][i]));
    }
  }
}

class Tracking {
  String id;
  String trackingNumber;
  String slug;
  String orderId;

  Tracking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trackingNumber = json['tracking_number'];
    slug = json['slug'];
    orderId = json['order_id'];
  }
}
