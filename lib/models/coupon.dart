class Coupons {
  var coupons = [];
  Coupons.getListCoupons(List a){
    for(var i in a){
      coupons.add(Coupon.fromJson(i));
      //print(i.toString());
    }
    //print("hallo ${coupons.length}");
  }

}

class Coupon {
  var amount;
  var code;
  var message;
  var id;

  Coupon.fromJson(Map<String, dynamic> json){   
    try {
      amount = json["amount"];
      code = json["code"];
      id = json["id"];
      message = "Hello";
    } catch(e) {
      print(e.toString());
    }
  }
}