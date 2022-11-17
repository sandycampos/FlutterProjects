import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(_gifData["images"]["fixed_width"]["url"]);
                },
              )
            ],
            iconTheme: IconThemeData(color: Colors.white),
            title:
                Text(_gifData["title"], style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black),
        backgroundColor: Colors.black,
        body: Center(
            child: Image.network(_gifData["images"]["fixed_width"]["url"])));
  }
}
