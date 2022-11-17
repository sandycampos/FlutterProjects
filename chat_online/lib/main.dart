import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

void main() async{

  //acessa banco e cria coleção, documento e mapa
  //Firestore.instance.collection("teste").document("teste").setData({"teste" : "teste"});

  /*DocumentSnapshot snapshot = await Firestore.instance.collection("usuarios").document("spcampos").get();
  print(snapshot.data);

  QuerySnapshot snapshot = await Firestore.instance.collection("usuarios").getDocuments();
  
  for(DocumentSnapshot doc in snapshot.documents){
    print(doc.id);
  }print(snapshot.documents);
  
  Firestore.instance.collection("mensagens").snapshots().listen((snapshot){
    for(DocumentSnapshot doc in snapshot.documents)
    print(doc.data);
  });*/

  runApp(MyApp());
}

final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<Null> _ensureLogedIn() async{
    GoogleSignInAccount user = googleSignIn.currentUser;
    //autenticação no google
    if(user == null)
      user = await googleSignIn.signInSilently();
    if(user == null)
    //exibe um janela pedindo para o user fazer login
      user = await googleSignIn.signIn();
    //autenticação no firebase
    if(await auth.currentUser() == null){
      GoogleSignInAuthentication credentials = 
        await googleSignIn.currentUser.authentication;
      //await auth.signWithGoogle( 
      await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: credentials.idToken, 
        accessToken: credentials.accessToken));
  }
}

_handleSubmitted(String text) async{
  await _ensureLogedIn();
  _sendMessage(text: text);
}

//estrutura do banco de dados
_sendMessage({String text, String imgUrl}){
  Firestore.instance.collection("mensagens").add(
    {
      "text": text,
      "imgUrl": imgUrl,
      "senderMessage": googleSignIn.currentUser.displayName,
      "senderPhotoUrl": googleSignIn.currentUser.photoUrl,
      "senderDate": new DateTime.now().toIso8601String()
    }
  );
}

class MyApp extends StatelessWidget {

final ThemeData kIOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light
  );

  final ThemeData kDefaultTheme = ThemeData(
    primarySwatch: Colors.purple,
    accentColor: Colors.orangeAccent[400]
    );

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          centerTitle: true,
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0 : 4,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              //Future ocorre uma vez, Stream ocorre sempre que houver modificação
              child: StreamBuilder( 
                //snapshots retorna stream responsável por observar mudanças no banco
                //orderBy com parâmetro para ordenar por horário
                stream: Firestore.instance.collection("mensagens").orderBy("senderDate").snapshots(), 
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case(ConnectionState.none):
                    case(ConnectionState.waiting):
                      return Center(
                        child: CircularProgressIndicator()
                        );
                  default:
                    return ListView.builder(
                      //ordem do scroll
                      reverse: true,
                      //.documents porque snapshot retorna documents 
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index){
                        List r = snapshot.data.documents.reversed.toList();
                        return ChatMessage(r[index].data);
                      },
                    );
                  }
                },
              )
            ),
            Divider(height: 1),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: TextComposer(),
            )
          ],
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  //para sinalizar se algo foi digitado
  bool _isComposing = false;
  final _textController = TextEditingController();

  void _reset(){
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  //função para enviar o texto para o banco de dados

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: Theme.of(context).platform == TargetPlatform.iOS ?
        BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]))
        ) :
        null,
        child: Row(children: <Widget>[
          //câmera
          Container(
            child: IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () async{
                await _ensureLogedIn();
                File imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
                if(imgFile == null) return;
                //Storage armazena arquivos e Database armazena dados
                //referencia o banco e especifica o caminho
                StorageUploadTask task = FirebaseStorage.instance.ref()
                //.child("photos"). para criar uma pasta mãe
                //converte o id e o tempo em string para nomear o arquivo
                  .child(googleSignIn.currentUser.id.toString() +
                    DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);
                  StorageTaskSnapshot taskSnapshot = await task.onComplete;
                  String url = await taskSnapshot.ref.getDownloadURL();
                  _sendMessage(imgUrl: url);
              },
            ),
          ),
          //input do chat
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(hintText: "Digite a sua mensagem"),
              onChanged: (text){
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              //enviar ao clicar no botão de confirmar do teclado
              onSubmitted: (text){
                _handleSubmitted(text);
                _reset();
              },
            ),
          ),
          //botão enviar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Theme.of(context).platform == TargetPlatform.iOS ?
            CupertinoButton(
              child: Text("Enviar"),
              onPressed: _isComposing ?
              (){_handleSubmitted(_textController.text);
              _reset();} :
              null
            ) :
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _isComposing ?
              (){_handleSubmitted(_textController.text);
              _reset();} :
              null)
        )]),
      ),
    );
  }
}

//estrutura das mensagens no corpo do app
class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> data;

  ChatMessage(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(children: <Widget>[
        //imagem do chat
        Container(
          margin: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage(data["senderPhotoUrl"]),
          ),
        ),
        //texto do chat
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Text(data["senderMessage"],
            style: Theme.of(context).textTheme.subhead),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: data["imgUrl"] != null ?
              Image.network(data["imgUrl"], width: 250) :
              Text(data["text"]
              ),
            )
            ]        
          ),
        )
      ])
    );
  }
}

