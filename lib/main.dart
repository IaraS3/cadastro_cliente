import 'package:cadastro_cliente/banco_local.dart';
import 'package:cadastro_cliente/usuario.dart';
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
  final banco = BancoLocal(); // Objeto responsável por SQLITE

  final id = TextEditingController(); // Controla o ID
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

    try {
      // Envia os dados para o BD
      await banco.cadastrar(nome.text, email.text);

      nome.clear(); // Limpa o campo nome.
      email.clear(); // Limpa o campo e-mail.

      setState(() {
        resultado = 'Usuário cadastrado com SUCESSO!!!';
      });
    } catch (erro) {
      // Executo caso ocorra um exceção.
      print('Erro as cadastrar usuário: $erro');

      setState(() {
        resultado = 'Não foi possível cadastar o usuário';
      });
    }
  }

  Future<void> consultarUsuarios() async {
    final usuarios = await banco.listar(); // Busca os registros no BD

    try {
      String texto = ''; // Armazena o resultado da consulta

      // Percorre os usuários encotrados.
      for (var usuario in usuarios) {
        texto += '${usuario['id']} - ${usuario['nome']}\n';
        texto += '${usuario['email']}\n\n';
      }

      setState(() {
        resultado = texto; // Atualiza o texto da tela.
      });
    } catch (erro) {
      print('Operação de consulta finalizada!!!');
    }
  }

  @override
  void dispose() {
    nome.dispose(); // Libera o controlador nome
    email.dispose(); // Libera o controlador nome
    super.dispose(); // Libera o controlador nome
  }

  // Altera o nome e o e-mail de um usuário
  Future<void> alterarUsuario() async {
    try {
      int? codigo = int.tryParse(id.text); // Conversão do ID para inteiro

      // Verifica os campos necessários
      if (codigo == null || nome.text.isEmpty || email.text.isEmpty) {
        setState(() {
          resultado = 'Informe um ID válido, nome e e-mail';
        });
        return;
      }

      // Executa a alteração no SQLite
      int quantidade = await banco.alterar(codigo, nome.text, email.text);

      setState(() {
        if (quantidade > 0) {
          resultado = 'Usuário alterado com SUCESSO!!!';
        } else {
          resultado = 'Usuário não encontrado!!!';
        }
      });

      id.clear();
      nome.clear();
      email.clear();
    } catch (erro) {
      print('Erro ao alterar: $erro');

      setState(() {
        resultado = 'Não foi possível alterar o usuário!!!';
      });
    }
  }

  // Excluir um usuário do SQLite
  Future<void> excluirUsuario() async {
    try {
      int? codigo = int.tryParse(id.text); //Converte o ID

      // Simulação de erro
      if (codigo == 999) {
        throw Exception('Isto é uma falha simulada!!!');
      }

      // Verifica de o ID foi informado corretamente
      if (codigo == null) {
        setState(() {
          resultado = 'Informe um ID válido!!!';
        });
        return;
      }

      int quantidade = await banco.excluir(codigo);

      setState(() {
        if (quantidade > 0) {
          resultado = 'Usuário excluído com sucesso!!!';
        } else {
          resultado = 'Usuário não encontrado!!!';
        }
      });

      id.clear(); // Limpa somente o campo ID
    } catch (erro) {
      print('Erro ao excluir: $erro');

      setState(() {
        resultado = ('Não foi possível excluir o usuário');
      });
    }
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
            // Campo para digitar o ID.
            TextField(
              controller: id,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID do usuário (Alterar ou excluir)',
              ),
            ),

            // Campo para digitar o nome.
            TextField(
              controller: nome,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),

            // Campo para digitar o e-mail.
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: 'E-mail'),
            ),

            const SizedBox(height: 20),

            // Botão cadastro
            ElevatedButton(
              onPressed: cadastrarUsuario,
              child: const Text('Cadastrar'),
            ),

            // Botão Consultar
            ElevatedButton(
              onPressed: consultarUsuarios,
              child: const Text('Consultar usuários'),
            ),

            // Botão para alterar (Ainda sem funcionalidade)
            ElevatedButton(
              onPressed: alterarUsuario,
              child: const Text('Alterar usuário'),
            ),

            // Botão para Excluir (Ainda sem funcionalidade)
            ElevatedButton(
              onPressed: excluirUsuario,
              child: const Text('Excluir Usuário'),
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
