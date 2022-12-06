import 'package:flutter/material.dart';
import 'dart:io';
import '../helpers/contact_helper.dart';

import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  /// um contato pode ou não ser recebido da tela principal
  final Contact? contact;

  /// construtor
  const ContactPage({this.contact, Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  ///controladores para os campos de texto. Por meio destes controladores
  ///é possível editar os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  /// variáveis globais, a primeira utilizada para verificar se veio um contato
  /// da outra página, a segunda é uma booleana para auxiliar no controle dos
  /// campos de texto e terceira para ajudar com o foco, ou seja, onde o cursor
  /// está no momento. Isto é interessante no processo de validação.
  late Contact _editedContact;
  bool _userEdited = false;
  final _nameFocus = FocusNode();

  /// chamado quando a página inicia.
  @override
  void initState() {
    super.initState();
    /// aqui é verificado se veio um contato, é uma forma que esta classe tem
    /// de se comunicar com a classe anterior
    if(widget.contact == null){
      /// se o widget é nulo, então é um novo contato.
      _editedContact = Contact();
    }else {
      /// caso contrário não é um novo contato, mas edição de um contato já
      /// existente.
      _editedContact = widget.contact!;

      /// nesse caso, espera-se que os textos que vieram sejam mostrados, para
      /// isso serve este trecho.
      _nameController.text = _editedContact.name!;
      _emailController.text = _editedContact.email!;
      _phoneController.text = _editedContact.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// este widget impede que a página seja fechada automaticamente por meio
    /// da seta voltar - há um tratamento mais abaixo.
    return WillPopScope (
      onWillPop: () => _requestPop() ,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? 'Novo Contato'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            /// caso não haja um nome, o foco, ou seja, o cursor vai para o
            /// campo nome, em vez de salvar o contato
            if(_editedContact.name != null && _editedContact.name!.isNotEmpty){
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 150,
                  height:150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.img != null?
                      FileImage(File(_editedContact.img!)):
                      const AssetImage('images/person.png') as ImageProvider,
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap: (){
                  /// abre a câmera e salva o caminho da foto tirada no banco
                  ImagePicker().pickImage(source: ImageSource.camera).
                  then((file){
                    if(file == null){
                    return;
                  }
                  setState(() {
                    _editedContact.img = file.path;
                  });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// esta função apenas verifica se houve edição ou não de algum dado, caso
  /// tenha havido edição, é perguntado se deseja descartar.
  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context, builder:(context){
        return AlertDialog(
          title: const Text('Descartar Alterações'),
          content: const Text('Se sair as alterações serão perdidas'),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: const Text('Cancelar')),
           TextButton(onPressed: (){
              Navigator.pop(context);
              Navigator.pop(context);
            }, child: const Text('Sim')),
          ]
        );
      });
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

}
