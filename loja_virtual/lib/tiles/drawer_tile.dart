import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {

  final IconData icon;
  final String text;
  final PageController controller;
  final int page;

  DrawerTile(this.icon, this.text, this.controller, this.page);

  @override
  Widget build(BuildContext context) {
    //ícones com efeito visual
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Navigator.of(context).pop();
          controller.jumpToPage(page);
        },
        //especificar a altura 
        child: Container(
          height: 60,
          child: Row(
            children: <Widget>[
              //icone
              Icon(icon,
              color: controller.page.round() == page ? Theme.of(context).primaryColor : Colors.grey[700]),
              //.page retorna um double e a minha página é inteira
              //espaçamento
              SizedBox(width: 32),
              //texto
              Text(text,
              style: TextStyle(color: controller.page.round() == page ? Theme.of(context).primaryColor : Colors.grey[700]))          
            ],
          ),
        ),
      ),
    );
  }
}
