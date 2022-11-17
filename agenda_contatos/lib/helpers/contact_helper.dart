import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn= "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal(); //construtor interno
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {     //chama o banco
    if (_db != null){                //se inicializado
      return _db;                   //retona banco
      } else {                     //senão
        _db = await initDb();     //inicia o banco
        return _db;              //e retorna os valores
        }
  }

  Future<Database> initDb() async {                        //inicia o banco
    final databasesPath = await getDatabasesPath();       //caminho
    final path = join(databasesPath, "contactsnew.db");  //caminho e nome
  
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async{    //se não tiver banco
      await db.execute(                                                                            //cria o banco ao inicializar
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY,"
        "$nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"

      );
    });
  
  }

  Future<Contact> saveContact(Contact contact) async{                       //chamar "salvar contato" e passar contato
    Database dbContact = await db;                                         //obter banco
    contact.id = await dbContact.insert(contactTable, contact.toMap());   //inserir contato na tabela e obter id
    return contact;                                                      //obter contato no futuro
  }

  Future<Contact> getContact(int id) async{                                 //retorna o id do contato
    Database dbContact = await db;                                         //banco
  List<Map> maps = await dbContact.query(contactTable,                    //solicitação
  columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],  //especifica colunas
  where: "$idColumn = ?",                                               //? = [id]
  whereArgs: [id]);                                                    //idColumn = [id]
  if (maps.length > 0){                                               //se obter algum contato
    return Contact.fromMap(maps.first);                              //retorna
  } else{
    return null;
    }
  }

  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async{ 
    Database dbContact = await db;
    //Obtendo o retorno da consulta, em uma lista dinamica
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    //Instanciando a lista
    List<Contact> listContact = List();
    for (Map m in listMap){                                               
    //faz a conversao do Map Dinamica em um objeto da classe Contato
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact{

Contact();

int id;
String name;
String email;
String phone;
String img;

  Contact.fromMap(Map map){ //contrutor para o mapa
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap(){ //transformando em mapa
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn:img,
    };
    
    if(idColumn != null){
      map[idColumn] = id;
    } return map; 
          
  }

  @override
  String toString(){
    return "Contacts(id: $id, name: $name, email: $email, phone: $phone; img: $img)";
  }

}

