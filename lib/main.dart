import 'package:cadastro_cliente/banco_local.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Biblioteca do SQLite
import 'package:path/path.dart'; // Manipula caminho

void main() {
  runApp(const MeuAplicativo()); // Inicia o app
}

// Classe principal do APP.
class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaInicial(), // Primeira tela.
    ); // Material App
  }
}

// Tela de Cadastro e consulta
class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final banco = BancoLocal(); // Objeti responsável por SQLITE
  final id = TextEditingController();
  final nome = TextEditingController(); // Controla o campo nome
  final email = TextEditingController(); // Controla o campo e-mail

  String resultado = ''; // Mensagem exibida na tela

  // Cadastra um usuário no SQLite
  Future<void> cadastrarUsuario() async {
    // Valida se os campos foram preenchidos
    if (nome.text.isEmpty || email.text.isEmpty) {
      setState(() {
        resultado = 'Preencha todos os Campos!!!';
      });
      return;
    }

    // Envia os dados para o BD
    await banco.cadastrar(nome.text, email.text);

    nome.clear(); // Limpa o campo nome.
    email.clear(); // Limpa o campo e-mail.

    setState(() {
      resultado = 'Usuário cadastrado com SUCESSO!!!';
    });
  }

  Future<void> consultarUsuarios() async {
    final usuarios = await banco.listar(); // Busca os registros no BD

    String texto = ''; // Armazena o resultado da consulta

    // Percorre os usuários encotrados.
    for (var usuario in usuarios) {
      texto += '${usuario['id']} - ${usuario['nome']}\n';
      texto += '${usuario['email']}\n\n';
    }

    setState(() {
      resultado = texto; // Atualiza o texto da tela.
    });
  }

  @override
  void dispose() {
    nome.dispose(); // Libera o controlador nome
    email.dispose(); // Libera o controlador nome
    super.dispose(); // Libera o controlador nome
  }

  //Alterar o nome e o email de um usuario
  Future<void> alterarUsuario() async {
    int? codigo = int.tryParse(id.text); // Converte o id para inteiro

    //Verifica os campos necessários
    if (codigo == null || nome.text.isEmpty || email.text.isEmpty) {
      setState(() {
        // Atualiza o texto da tela.
        resultado = 'Informe um ID válido, nome e e-mail!';
      });
      return;
    }

    // Execute a alteração no SQLite
    int quantidade = await banco.alterar(codigo, nome.text, email.text);
    setState(() {
      if (quantidade > 0) {
        resultado = 'Usuário alterado com sucesso!';
      } else {
        resultado = 'Nenhum usuário encontrado';
      }
    });

    id.clear();
    nome.clear();
    email.clear();
  }

  //Excluir um usuario do SQLite
  Future<void> excluirUsuario() async {
    int? codigo = int.tryParse(id.text); // Converte o id para inteiro

    //Verifica se o campo id foi preenchido corretamente
    if (codigo == null) {
      setState(() {
        resultado = 'Informe um ID válido!';
      });
      return;
    }

    // Execute a exclusão no SQLite
    int quantidade = await banco.excluir(codigo);
    setState(() {
      if (quantidade > 0) {
        resultado = 'Usuário excluído com sucesso!';
      } else {
        resultado = 'Usuário não encontrado';
      }
    });

    id.clear(); // Limpa somenteo campo id
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de usuários')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // Campo para digitar o id.
            TextField(
              controller: id,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID do usuário (para alterar ou excluir)',
              ),
            ),

            // Campo para digitar o nome.
            TextField(
              controller: nome,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),

            // Campo para digitar o nome.
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: 'E-mail'),
            ),

            const SizedBox(height: 20),

            // Botão cadastro (Sem funcionalidade)
            ElevatedButton(
              onPressed: cadastrarUsuario,
              child: const Text('Cadastrar'),
            ),

            // Botão Consultar (Sem funcionalidade).
            ElevatedButton(
              onPressed: consultarUsuarios,
              child: const Text('Consultar usuários'),
            ),

            // Botão Alterar (Sem funcionalidade).
            ElevatedButton(
              onPressed: alterarUsuario,
              child: const Text('Alterar usuário'),
            ),

            // Botão excluir (Sem funcionalidade).
            ElevatedButton(
              onPressed: excluirUsuario,
              child: const Text('Excluir usuário'),
            ),

            const SizedBox(height: 20),

            // Espaço reservado para exibir os resultados
            Expanded(child: SingleChildScrollView(child: Text(resultado))),
          ],
        ),
      ),
    );
  }
}
