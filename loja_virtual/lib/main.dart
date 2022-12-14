import 'package:flutter/material.dart';
import 'package:loja_virtual/models/cart_model.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/home_screen.dart';
import 'package:loja_virtual/screens/login_screen.dart';
import 'package:loja_virtual/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
        //tudo que estiver abaixo do ScopedModel terá acesso ao UserModel e será modificado com base nele
        model: UserModel(),
        child: ScopedModelDescendant<UserModel>(
          //UserModel para especificar o tipo do (model)
          builder: (context, child, model) {
            return ScopedModel<CartModel>(
              model: CartModel(model),
              child: MaterialApp(
                title: "Loja Virtual",
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                    primaryColor: Color.fromARGB(255, 4, 125, 141)),
                debugShowCheckedModeBanner: false,
                home: HomeScreen(),
              ),
            );
          },
        ));
  }
}
