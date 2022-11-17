import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/login_screen.dart';
import 'package:loja_virtual/tiles/drawer_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  //construtor para acessar o _pageController
  CustomDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {
    Widget _buildDrawerBack() => Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color.fromARGB(255, 203, 236, 241), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)));

    return Drawer(
      child: Stack(
        children: <Widget>[
          _buildDrawerBack(),
          ListView(
            padding: EdgeInsets.only(left: 32, top: 16),
            //top para dispositivos ios
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(bottom: 8),
                  //traço apenas abaixo para separar o conteúdo
                  padding: EdgeInsets.fromLTRB(0, 16, 16, 8),
                  //alinhamento do texto
                  height: 170,
                  child: Stack(
                    children: <Widget>[
                      //stack para posicionar os componentes dentro do espaço
                      Positioned(
                          top: 8,
                          bottom: 0,
                          child: Text("Loja\nVirtual",
                              style: TextStyle(
                                  fontSize: 34, fontWeight: FontWeight.bold))),
                      Positioned(
                          left: 0,
                          bottom: 0,
                          child: ScopedModelDescendant<UserModel>(
                            builder: (context, child, model) {
                              print(model.isLoggedIn);
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "Olá, ${!model.isLoggedIn() ? "" : model.userData["name"]}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    GestureDetector(
                                      child: Text(
                                          !model.isLoggedIn()
                                              ? "Entre ou cadastre-se >"
                                              : "Sair",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      onTap: () {
                                        if (!model.isLoggedIn())
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()));
                                        else
                                          model.signOut();
                                      },
                                    )
                                  ]);
                            },
                          ))
                    ],
                  )),
              Divider(),
              DrawerTile(Icons.home, "Início", pageController, 0),
              DrawerTile(Icons.list, "Produtos", pageController, 1),
              DrawerTile(Icons.location_on, "Lojas", pageController, 2),
              DrawerTile(Icons.playlist_add_check, "Meus Pedidos", pageController, 3)
            ],
          )
        ],
      ),
    );
  }
}
