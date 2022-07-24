import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';


/// classe singleton que ficará responsável pelas operações de bancos.

/// abaixo existem variáveis que foram criadas para evitar erros de digitação
const String contactTable = 'contactTable';
const String idColumn = "idColumn";
const String nameColumn = 'nameColumn';
const String emailColumn = 'emailColumn';
const String phoneColumn = 'phoneColumn';
const String imgColumn = 'imgColumn';
///-----------------------------------------------------------------------------

/// A classe de banco inicializa o banco e fornece ajuda com suas operações
class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

   Database? _db;

  Future<Database> get db async {

    if( _db != null){
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

/// função que será executada uma vez para criar o banco
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contact.db');

    return await openDatabase(path, version: 1, onCreate: (Database db,
        int newerVersion) async{
      await db.execute(
        'CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, '
            '$nameColumn TEXT, $emailColumn Text, $phoneColumn TEXT,'
            ' $imgColumn TEXT)'
      );
    });
  }

/// ...salvando no banco
  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

/// ...buscando um contato
  Future<Contact?> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
    columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
    where: '$idColumn = ?',
    whereArgs: [id]);
    if(maps.isNotEmpty){
      return Contact.fromMap(maps.first);
    }else {
      return null;
    }
  }

/// ...deletando um contato
  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: '$idColumn = ?',
    whereArgs: [id]);
  }

/// ...atualizando um contato
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where:
    '$idColumn = ?', whereArgs: [contact.id]);
  }

/// ...buscando uma lista com todos os contatos
  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List<Map> listMap = await dbContact.rawQuery("SELECT * from $contactTable");
    List<Contact> listContact = [];
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

/// ...retorna o total de contatos
  Future<int?> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

/// apenas fecha o banco de dados
  Future<void> close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}
///-----------------------------------------------------------------------------
/// classe contato--------------------------------------------------------------


class Contact {
   int? id;
   String? name;
   String? email;
   String? phone;
   String? img;

/// método para converter de map------------------------------------------------
   Contact.fromMap(Map map){
     id = map[idColumn];
     name = map[nameColumn];
     email = map[emailColumn];
     phone = map[phoneColumn];
     img = map[imgColumn];
   }
///-----------------------------------------------------------------------------
/// método para converter para map----------------------------------------------
   Map<String, dynamic> toMap() {
     Map<String, dynamic> map = {
       nameColumn: name,
       emailColumn: email,
       phoneColumn: phone,
       imgColumn: img
     };
     if(id != null){
       map[idColumn] = id;
     }
     return map;
   }

   @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img:'
        ' $img';
  }
}
/// fim classe contact----------------------------------------------------------