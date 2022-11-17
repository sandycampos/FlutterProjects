import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact}); // contrutor para passar contato que quero editar já com os dados {opcional porque criar/editar}

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode(); //foco para o input name

  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState(){
    super.initState();

    if(widget.contact == null){
      _editedContact = Contact();
    } else{
      _editedContact = Contact.fromMap(widget.contact.toMap());
    }

    _nameController.text = _editedContact.name;
    _emailController.text = _editedContact.email;
    _phoneController.text = _editedContact.phone;

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(_editedContact.name ?? "Novo Contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_editedContact.name != null && _editedContact.name.isNotEmpty){  //se não nulo ou não vazio
            Navigator.pop(context, _editedContact);                          //salva e volta pra homepage mostrando o contato salvo
          } else{                                                           //senão
            FocusScope.of(context).requestFocus(_nameFocus);               //indica que o nome é vazio ou nulo   
          }
        },
        /*Funcionamento do Navigator =
        Pilha                           homepage
        papel1                          contactpage
        papel2                          anypage
        papel3    push = papel4    pop = remove último elemento(papel4)
         */
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _editedContact.img != null ?               //IMAGEM
                        FileImage(File(_editedContact.img)) :
                        AssetImage('images/person2.png'),
                        fit: BoxFit.cover
                      )
                  ),
                ),
                onTap: (){ ImagePicker.pickImage(source: ImageSource.camera).then((file){
                  if (file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                });
                }
            ),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(
                  labelText: "Nome"),
              onChanged: (text){
                _userEdited = true;
                setState(() {                      //altera o title do appbar
                  _editedContact.name = text;
                });
              },
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: "E-mail"),
              onChanged: (text){
                _userEdited = true;
                _editedContact.email = text;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                  labelText: "Telefone"),
              onChanged: (text){
                _userEdited = true;
                _editedContact.phone = text;
              },
              keyboardType: TextInputType.phone,
            )
          ],
        ),
      ),
    ));
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Descartar as alterações?"),
          content: Text("Se sair as alterações serão perdidas."),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: (){
                Navigator.pop(context);         //pop dialog      =>contactpage
              },
            ),
            FlatButton(
              child: Text("Sim"),
              onPressed: (){
                Navigator.pop(context);          //pop dialog
                Navigator.pop(context);         //pop contactpage    =>homepage
              },
            )
          ],
        );
      });
      return Future.value(false);              //não sair automaticamente ?false
    } else{
      return Future.value(true);           //sair automaticamente ?true
    }
  }

}