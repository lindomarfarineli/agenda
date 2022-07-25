import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

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
    setState(() {
      helper.getAllContacts().then((list) =>  contacts = list );
    });
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
        onPressed: (){},
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body:  ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index){

          },
    ),
    );
  }
}
