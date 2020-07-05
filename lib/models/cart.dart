import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'product.dart';
import '../models/product.dart';
import '../models/address.dart';
import '../models/shipping_method.dart';
import '../models/payment_method.dart';
import '../models/user.dart';
import '../common/constants.dart';

class CartModel with ChangeNotifier {
  CartModel(){
    initData();
  }

  Address address;
  ShippingMethod shippingMethod;
  PaymentMethod paymentMethod;
  double amount = 0.00;
  String coupon;

  // The IDs and product Object currently in the cart.
  Map<int, Product> _item = {};

  // The IDs and quantities of products currently in the cart.
  Map<String, int> _productsInCart = {};
  Map<String, int> get productsInCart => Map.from(_productsInCart);

  // The IDs and product variation of products currently in the cart.
  Map<String, ProductVariation> _productVariationInCart = {};
  Map<String, ProductVariation> get productVariationInCart => Map.from(_productVariationInCart);

  //This is used for magento
  //The IDs and product sku of products currently in the cart.
  Map<String, String> _productSkuInCart = {};
  Map<String, String> get productSkuInCart => Map.from(_productSkuInCart);

  int get totalCartQuantity => _productsInCart.values.fold(0, (v, e) => v + e);

  double getSubTotal(){
    return _productsInCart.keys.fold(0.0, (sum, key){
      if(_productVariationInCart[key] != null && _productVariationInCart[key].price != null && _productVariationInCart[key].price.isNotEmpty){
        return sum + double.parse(_productVariationInCart[key].price) * _productsInCart[key];
      }else{
        var productId;
        if (key.contains("-")) {
          productId = int.parse(key.split("-")[0]);
        } else {
          productId = int.parse(key);
        }
        if(_item[productId].price != null && _item[productId].price.isNotEmpty){
          return sum +  double.parse(_item[productId].price) * _productsInCart[key];
        }
        return sum;
      }
    });
  }

  double getTotal(){
    return getSubTotal() - getSubTotal()*amount/100;
  }

  // Adds a product to the cart.
  void addProductToCart({Product product, int quantity = 1, ProductVariation variation, isSaveLocal = true}) {
    if(isSaveLocal) saveCartToLocal(product: product,quantity: quantity,variation: variation);

    var key = "${product.id}";
    if (variation != null) {
      if (variation.id != null) {
        key += "-" + "${variation.id}";
      }
      for (var attribute in variation.attributes) {
        if (attribute.id == null) {
          key += "-" + attribute.name + attribute.option;
        }
      }
    }
    if (!_productsInCart.containsKey(key)) {
      _productsInCart[key] = quantity;
    } else {
      _productsInCart[key] += quantity;
    }
    _item[product.id] = product;
    _productVariationInCart[key] = variation;
    _productSkuInCart[key] = product.sku;

    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    if (_productsInCart.containsKey(key)) {
      _productsInCart[key] = quantity;
      notifyListeners();
    }
  }

  // Removes an item from the cart.
  void removeItemFromCart(String key) {
    if (_productsInCart.containsKey(key)) {
      removeProductLocal(int.parse(key));
      if (_productsInCart[key] == 1) {
        _productsInCart.remove(key);
        _productVariationInCart.remove(key);
        _productSkuInCart.remove(key);
      } else {
        _productsInCart[key]--;
      }
    }
    notifyListeners();
  }

  void setAddress(data){
    address = data;
    saveShippingAddress(data);
  }

  Future getAddress()async{
    if(address == null){
      await getShippingAddress();
    }
    return address;
  }
  void setShippingMethod(data){
    shippingMethod = data;
  }

  void setPaymentMethod(data){
    paymentMethod = data;
  }

  // Returns the Product instance matching the provided id.
  Product getProductById(int id) {
    return _item[id];
  }

  // Returns the Product instance matching the provided id.
  ProductVariation getProductVariationById(String key) {
    return _productVariationInCart[key];
  }

  // Removes everything from the cart.
  void clearCart() {
    clearCartLocal();
    _productsInCart.clear();
    _item.clear();
    _productVariationInCart.clear();
    _productSkuInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    coupon = null;
    amount = 0.00;
    notifyListeners();
  }

  void initData()async{
    getShippingAddress();
    getCartInLocal();
  }

  void saveShippingAddress(Address address) async{
    final LocalStorage storage = new LocalStorage("fstore");
    try{
      final ready = await storage.ready;
      if(ready){
        await storage.setItem(kLocalKey["shippingAddress"], address);
      }
    }catch(err){
      print(err);
    }
  }

  Future getShippingAddress() async{
    final LocalStorage storage = new LocalStorage("fstore");
    try{
      final ready = await storage.ready;
      if(ready){
        final json = storage.getItem(kLocalKey["shippingAddress"]);
        if(json != null){
          address = Address.fromLocalJson(json);
          return address;
        }else{
          final userJson = storage.getItem(kLocalKey["userInfo"]);
          if(userJson != null){
            final user = User.fromLocalJson(userJson);
            address = Address(firstName: user.firstName, lastName: user.lastName, email: user.email);
            return address;
          }
        }
      }
      return null;
    }catch(err){
      print(err);
      return null;
    }
  }

  void saveCartToLocal({Product product, int quantity = 1, ProductVariation variation}) async{
    final LocalStorage storage = new LocalStorage("fstore");
    try{
      final ready = await storage.ready;
      if(ready){
        List items = await storage.getItem(kLocalKey["cart"]);
        if(items != null && items.isNotEmpty){
          items.add({"product": product.toJson(), "quantity": quantity, "variation": variation.toString()});
        }else{
          items = [{"product": product.toJson(), "quantity": quantity, "variation": variation.toString()}];
        }
        await storage.setItem(kLocalKey["cart"], items);
      }
    }catch(err){
      print(err);
    }
  }

  void getCartInLocal() async{
    final LocalStorage storage = new LocalStorage("fstore");
    try{
      final ready = await storage.ready;
      if(ready){
        List items = await storage.getItem(kLocalKey["cart"]);
        if(items != null && items.isNotEmpty){
          items.forEach((item){
            addProductToCart(product: Product.fromLocalJson(item["product"]), quantity: item["quantity"], variation: item["variation"] != "null" ? ProductVariation.fromLocalJson(item["variation"]) : null, isSaveLocal: false);
          });
        }
      }
    }catch(err){
      print(err);
    }
  }

  void clearCartLocal() async{
    final LocalStorage storage = new LocalStorage("fstore");
    try{
      final ready = await storage.ready;
      if(ready){
        storage.deleteItem(kLocalKey["cart"]);
      }
    }catch(err){
      print(err);
    }
  }

  void removeProductLocal(int productId) async{
    final LocalStorage storage = new LocalStorage("fstore");
    try{
      final ready = await storage.ready;
      if(ready){
        List items = await storage.getItem(kLocalKey["cart"]);
        if(items != null && items.isNotEmpty){
          var item = items.firstWhere((item)=>Product.fromLocalJson(item["product"]).id == productId, orElse: ()=>null);
          if(item != null){
            if(item["quantity"] == 1){
              items.remove(item);
            }else{
              item["quantity"]--;
            }
          }
          await storage.setItem(kLocalKey["cart"], items);
        }

      }
    }catch(err){
      print(err);
    }
  }
}
