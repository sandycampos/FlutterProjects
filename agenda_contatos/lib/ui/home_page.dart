import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}  //constantes

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  /*@override
  void initState() {
    super.initState();

    Contact c = Contact();
    c.name = "Sabrina";
    c.email = "sabrina@gmail.com";
    c.phone = "984873056";
    c.img = "imgtest3";

    helper.saveContact(c);

    //helper.deleteContact(2);

    helper.getAllContacts().then((list) {
      print(list);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,

          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) { //função para retornar o item da minha posição
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(padding: EdgeInsets.all(10),
        child: Row(children: <Widget>[
          Container(                                //imagem redonda
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: contacts[index].img != null ? 
                FileImage(File(contacts[index].img)) : 
                AssetImage('images/person2.png'),
                fit: BoxFit.cover)
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text(contacts[index].name ?? "",
                style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.bold)
                ),
                Text(contacts[index].email ?? "",
                style: TextStyle(fontSize: 18)
                ),
                Text(contacts[index].phone ?? "",
                style: TextStyle(fontSize: 18)
                )],
            )),
          ]
        )),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context){
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  child: Text("Ligar", 
                  style: TextStyle(color: Colors.red, fontSize: 20)),
                  onPressed: (){
                    launch("tel:${contacts[index].phone}");
                    Navigator.pop(context);
                  },
              ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  child: Text("Editar", 
                  style: TextStyle(color: Colors.red, fontSize: 20)),
                  onPressed: (){
                    Navigator.pop(context);
                    _showContactPage(contact: contacts[index]);
                  },
              ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: FlatButton(
                  child: Text("Excluir", 
                  style: TextStyle(color: Colors.red, fontSize: 20)),
                  onPressed: (){
                    helper.deleteContact(contacts[index].id);
                    setState(() {
                      contacts.removeAt(index);
                      Navigator.pop(context);
                    });
                  },
              ),
              ),
            ],
          ),
        );
      } 
      );
    });
  }

  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(context,                            //recebendo contato da ContactPage após salvar
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)) //envia os dados do meu contact para ContactPage
    );
    if(recContact != null){                        //se retornou contato
      if(contact != null){                        //se enviei contato
        await helper.updateContact(recContact);
      } else{                                   //se não enviei contato, mas retornou algum
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      break;
      case OrderOptions.orderza:
        contacts.sort((a, b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
      break;
      }
      setState(() {

      });
  }
}