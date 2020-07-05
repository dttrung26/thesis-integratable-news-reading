import 'package:flutter/material.dart';
import '../services/index.dart';
import '../models/address.dart';

class ShippingMethodModel extends ChangeNotifier{
  Services _service = Services();
  List<ShippingMethod> shippingMethods;
  bool isLoading = true;
  String message;

  void getShippingMethods({Address address, String token}) async {
    try {
      shippingMethods = await _service.getShippingMethods(address: address, token: token);
      isLoading = false;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
    }
  }
}

class ShippingMethod{
  String id;
  String title;
  String description;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description
    };
  }

  ShippingMethod.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    title = parsedJson["title"];
    description = parsedJson["description"];
  }
}