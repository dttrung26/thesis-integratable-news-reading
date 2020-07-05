class Review {
  int id;
  int productId;
  String name;
  String email;
  String review;
  double rating;
  DateTime createdAt;

  Review.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    email = parsedJson["email"];
    review = parsedJson["review"];
    rating = double.parse(parsedJson["rating"].toString());
    createdAt = parsedJson["date_created"] != null ? DateTime.parse(parsedJson["date_created"]) : DateTime.now();
  }

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
