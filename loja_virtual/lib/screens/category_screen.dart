//grid e list view

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/product_data.dart';
import 'package:loja_virtual/tiles/product_tile.dart';

class CategoryScreen extends StatelessWidget {

  final DocumentSnapshot snapshot;

  CategoryScreen(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(snapshot.data["title"]),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.list))
            ],
          ),
        ),
        //query para snapshot de uma coleção de docs
        body: FutureBuilder<QuerySnapshot>(
          future: Firestore.instance.collection("products").document(snapshot.documentID).collection("items").getDocuments(),
          builder: (context, snapshot){
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            else
              return TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            //builder para não carregar todos os itens de uma vez
            GridView.builder(
              padding: EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.65,
              ),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){
                //conversão para não precisar alterar o código se mudar de banco, apenas o product_data

                ProductData data = ProductData.fromDocument(snapshot.data.documents[index]);
                data.category = this.snapshot.documentID;
                //salvando a categoria do produto no próprio produto, ver cart_product

                return ProductTile("grid", data);
              },
            ),
            ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index){

                ProductData data = ProductData.fromDocument(snapshot.data.documents[index]);
                data.category = this.snapshot.documentID;

                return ProductTile("list", data);
              },
            ),
          ],
          );
          })
      ),
    );
  }
}