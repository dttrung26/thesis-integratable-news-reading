import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../screens/products.dart';
import '../services/index.dart';
import 'app.dart';

class ProductModel with ChangeNotifier {
  Services _service = Services();
  List<List<Product>> products;
  String message;

  /// current select product id/name
  int categoryId;
  String categoryName;

  //list products for products screen
  bool isFetching = false;
  List<Product> productsList;
  String errMsg;
  bool isEnd;

  ProductVariation productVariation;

  changeProductVariation(ProductVariation variation) {
    productVariation = variation;
    notifyListeners();
  }

  Future<List<Product>> fetchProductLayout(config, lang) async {
    return await _service.fetchProductsLayout(config: config, lang: lang);
  }

  void fetchProductsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    notifyListeners();
  }

  void saveProducts(Map<String, dynamic> data) async {
    final LocalStorage storage = new LocalStorage("thesiscseiu");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["home"], data);
      }
    } catch (err) {
      print(err);
    }
  }

  void getProductsList(
      {categoryId, minPrice, maxPrice, orderBy, order, lang, page}) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final products = await _service.fetchProductsByCategory(
          categoryId: categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page);
      if (products.isEmpty) {
        isEnd = true;
      }

      if (page == 0 || page == 1) {
        productsList = products;
      } else {
        productsList = []..addAll(productsList)..addAll(products);
      }
      isFetching = false;
      notifyListeners();
    } catch (err) {
      errMsg = err.toString();
      isFetching = false;
      notifyListeners();
    }
  }

  void setProductsList(products) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }
}

class Product {
  int id;
  String sku;
  String name;
  String description;
  String permalink;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  double averageRating;
  double ratingCount;
  List<String> images;
  String imageFeature;
  List<ProductAttribute> attributes;
  int categoryId;
  String videoUrl;

  /// is to check the type affiliate, simple, variant
  String type;
  String affiliateUrl;

  Product.empty(int id) {
    this.id = id;
    name = 'Loading...';
    price = '0.0';
    imageFeature = '';
  }

  bool isEmptyProduct() {
    return name == 'Loading...' && price == '0.0' && imageFeature == '';
  }

  Product.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["id"];
      name = parsedJson["name"];
      type = parsedJson["type"];
      description = parsedJson["description"];
      permalink = parsedJson["permalink"];
      price = parsedJson["price"] != null ? parsedJson["price"].toString() : "";

      regularPrice = parsedJson["regular_price"] != null
          ? parsedJson["regular_price"].toString()
          : "";
      salePrice = parsedJson["sale_price"] != null
          ? parsedJson["sale_price"].toString()
          : null;
      onSale = parsedJson["on_sale"];
      inStock = parsedJson["in_stock"];

      averageRating = double.parse(parsedJson["average_rating"]);
      ratingCount = double.parse(parsedJson["rating_count"].toString());
      categoryId = parsedJson["categories"] != null &&
              parsedJson["categories"].length > 0
          ? parsedJson["categories"][0]["id"]
          : 0;

      List<ProductAttribute> attributeList = [];
      parsedJson["attributes"].forEach((item) {
        attributeList.add(ProductAttribute.fromJson(item));
      });
      attributes = attributeList;

      List<String> list = [];
      for (var item in parsedJson["images"]) {
        list.add(item["src"]);
      }
      images = list;
      imageFeature = images[0];

      // get video link
      var video = parsedJson['meta_data'].firstWhere(
        (item) =>
            item['key'] == '_video_url' || item['key'] == '_woofv_video_embed',
        orElse: () => null,
      );
      if (video != null) {
        videoUrl =
            video['value'] is String ? video['value'] : video['value']['url'];
      }

      // get affiliate link
      var productURL = parsedJson['meta_data'].firstWhere(
        (item) => item['key'].toString() == '_product_url',
        orElse: () => null,
      );
      if (productURL != null) {
        affiliateUrl = productURL['value'];
      } else
        affiliateUrl = null;
    } catch (e) {
      print(e);
    }
  }

  /// Show the product list
  static showList(
      {cateId, cateName, context, List<Product> products, config, noRouting}) {
    var categoryId = cateId ?? config['category'];
    var categoryName = cateName ?? config['name'];
    final product = Provider.of<ProductModel>(context, listen: false);

    // for caching current products list
    if (products != null) {
      product.setProductsList(products);
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductsPage(products: products, categoryId: categoryId)));
    }

    // for fetching beforehand
    if (categoryId != null)
      product.fetchProductsByCategory(
          categoryId: categoryId, categoryName: categoryName);

    product.setProductsList(List<Product>()); //clear old products
    product.getProductsList(
      categoryId: categoryId,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).locale,
    );

    if (noRouting == null)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductsPage(
                  products: products ?? [], categoryId: categoryId)));
    else
      return ProductsPage(products: products ?? [], categoryId: categoryId);

//    if (isMagic) {
//      Navigator.push(context,
//          MaterialPageRoute(builder: (context) => MagicScreen(products, categoryId, imageBanner)));
//    } else {
//      /// if the products list is not full just go straightaway
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) => ProductsPage(products, categoryId)));
//    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "name": name,
      "description": description,
      "permalink": permalink,
      "price": price,
      "regularPrice": regularPrice,
      "salePrice": salePrice,
      "onSale": onSale,
      "inStock": inStock,
      "averageRating": averageRating,
      "ratingCount": ratingCount,
      "images": images,
      "imageFeature": imageFeature,
      "attributes": attributes,
      "categoryId": categoryId
    };
  }

  Product.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      sku = json['sku'];
      name = json['name'];
      description = json['description'];
      permalink = json['permalink'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      salePrice = json['salePrice'];
      onSale = json['onSale'];
      inStock = json['inStock'];
      averageRating = json['averageRating'];
      ratingCount = json['ratingCount'];
      List<String> imgs = [];
      for (var item in json['images']) {
        imgs.add(item);
      }
      images = imgs;
      imageFeature = json['imageFeature'];
      List<ProductAttribute> attrs = [];
      for (var item in json['attributes']) {
        attrs.add(ProductAttribute.fromLocalJson(item));
      }
      attributes = attrs;
      categoryId = json['categoryId'];
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'Product { id: $id name: $name }';
}

class ProductAttribute {
  int id;
  String name;
  List options;

  ProductAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    options = parsedJson["options"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "options": options};
  }

  ProductAttribute.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      options = json['options'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Attribute {
  int id;
  String name;
  String option;

  Attribute();

  Attribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["option"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "option": option};
  }
}

class ProductVariation {
  int id;
  String sku;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  String imageFeature;
  List<Attribute> attributes = [];

  ProductVariation();

  ProductVariation.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    price = parsedJson["price"];
    regularPrice = parsedJson["regular_price"];
    salePrice = parsedJson["sale_price"];
    onSale = parsedJson["on_sale"];
    inStock = parsedJson["in_stock"];
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["attributes"].forEach((item) {
      attributeList.add(Attribute.fromJson(item));
    });
    attributes = attributeList;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "price": price,
      "regularPrice": regularPrice,
      "sale_price": salePrice,
      "on_sale": onSale,
      "in_stock": inStock,
      "image": {"src": imageFeature},
      "attributes": attributes.map((item) {
        return item.toJson();
      }).toList()
    };
  }

  ProductVariation.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      onSale = json['onSale'];
      salePrice = json['salePrice'];
      inStock = json['inStock'];
      imageFeature = json['imageFeature'];
      attributes = json['attributes'];
    } catch (e) {
      print(e.toString());
    }
  }
}
