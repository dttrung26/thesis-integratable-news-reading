import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../widgets/product/product_card_view.dart';

class ListCard extends StatelessWidget {
  final List<Product> data;
  final int id;

  ListCard(this.data, this.id);
  @override
  Widget build(BuildContext context) {
    return Container(
      height:  MediaQuery.of(context).size.width * 0.35 + 120,
      child: ListView.builder(
      scrollDirection: Axis.horizontal,
      key: ObjectKey(id),
      itemBuilder: (context, index){
        return ProductCard(item: data[index], width: MediaQuery.of(context).size.width * 0.35);
      },
      itemCount: data.length,
    ),
    );
  }
}