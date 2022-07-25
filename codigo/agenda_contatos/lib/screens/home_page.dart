import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// auxiliar da classe banco
  ContactHelper helper = ContactHelper();

  ///lista vazia que será carregada
  List<Contact> contacts = [];


  /// ao iniciar, a lista de contatos deverá ser carregada
  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body:  ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index){
            return _contactCard(context, index);
          },
    ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null? 
                          FileImage(File(contacts[index].img!)):
                          const AssetImage("images/person.png") as ImageProvider
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacts[index].name ?? '', style: const TextStyle(fontSize:
                    22, fontWeight: FontWeight.bold),),
                    Text(contacts[index].email ?? '', style: const TextStyle(fontSize:
                    18),),
                    Text(contacts[index].phone ?? '', style: const TextStyle(fontSize:
                    18),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  /// função que cria alguns botões quando se clica no contato, para alterar,
  /// excluir ou ligar se necessário.
  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){},
            builder: (context){
              return Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                    child: TextButton(
                      child: const Text('Ligar', style: TextStyle(color: Colors.red,
                      fontSize: 20),),
                      onPressed: () {
                        launchUrl(Uri(scheme: 'tel', path: contacts[index].phone));
                        Navigator.pop(context);
                      },
                    ),
                    ),
                    Padding(padding: const EdgeInsets.all(10),
                    child: TextButton(
                      child: const Text('Editar', style: TextStyle(color: Colors.red,
                      fontSize: 20),),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),),
                    Padding(padding: const EdgeInsets.all(10),
                    child: TextButton(
                      child: const Text('Excluir', style: TextStyle(color: Colors.red,
                      fontSize: 20),),
                      onPressed:(){
                        helper.deleteContact(contacts[index].id!);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),),
                  ],
                ),
              );
            }
          );
        });
  }

  /// salva ou atualiza o retorno de contactPage, de acordo com a necessidade
  void _showContactPage({Contact? contact}) async{
     final recContact = await Navigator.push(context,
    MaterialPageRoute(builder: (context) => ContactPage(contact: contact)),
    );
    if(recContact != null ){
      if(contact != null){
        await helper.updateContact(recContact);
      }else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  /// atualiza a lista de contatos
  void _getAllContacts(){
    setState(() {
      helper.getAllContacts().then((list) =>  contacts = list );
    });
  }

}
