//snapshot

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductData{

  String category;
  String id;
  String title;
  String description;
  double price;
  List sizes;
  List images;

  //contrutor
  ProductData.fromDocument(DocumentSnapshot snapshot){

  id = snapshot.documentID;
  title = snapshot.data["title"];
  description = snapshot.data["description"];
  //20(int) então 20 + 0.0
  price = snapshot.data["price"] + 0.0;
  sizes = snapshot.data["sizes"];
  images = snapshot.data["images"];
  }

  Map<String, dynamic> toResumedMap(){
    return {
      "title": title,
      "description": description,
      "price": price
    };
  }

}