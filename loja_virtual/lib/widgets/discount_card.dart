import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_model.dart';

class DiscountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
          title: Text("Cupom de desconto",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700]
          ),
          textAlign: TextAlign.center),
      leading: Icon(Icons.card_giftcard),
      trailing: Icon(Icons.add),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Digite seu cupom",
                border: OutlineInputBorder()
              ),
              initialValue: CartModel.of(context).couponCode ?? "",
              onFieldSubmitted: (text){
                Firestore.instance.collection("coupons").document(text).get().then(
                    (docSnap){
                      if (docSnap.data != null){
                        CartModel.of(context).setCoupon(text, docSnap.data["percent"]);
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text(
                            "Cupom de ${docSnap.data["percent"]}% aplicado!"
                          ),
                          backgroundColor: Theme.of(context).primaryColor
                          ));
                      } else {
                        CartModel.of(context).setCoupon(null, 0);
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text(
                                "Cupom inválido!"
                            ),
                                backgroundColor: Colors.redAccent
                            ));
                      }
                    }
                );
              },
            ),
          )
        ],
      )
    );
  }
}
