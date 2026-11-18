import 'package:cadastro_cliente/banco_local.dart';
import 'package:cadastro_cliente/usuario.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Biblioteca do SQLite
import 'package:path/path.dart'; // Manipula caminho
import 'validador_usuario.dart'; // Manipulo o objeto validador

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

    // Cria um objeto Usuario com dados da tela.
    Usuario usuario = Usuario(
      nome: nome.text.trim(), // Remove os espaços do ínicio e do fim da variável nome
      email: email.text.trim().toLowerCase(), // Remove espaços externos e converte o email para minusculo
    );

    // Enviar o objeto para a classe responsável pela validação
    // Retornar uma mensagem de erro ou null
    String? erroValidacao = ValidadorUsario.validaUsuario(usuario);


    // Verifica de existe algum erro de validação
    if (erroValidacao != null) {

      setState(() {
        resultado = erroValidacao; //Exibe a mensagem de erro
      });

      return; // Encerro o método sem acessar o BD
    }

    try {
      
      // Cria um objeto da classe Usuario
      Usuario usuario = Usuario(nome: nome.text, email: email.text,);
      
      // Envia os dados para o BD
      await banco.cadastrar(usuario);

      if (!mounted) return;

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
    } finally {
      // Executado com ou sem exceção.
      print('Operação de inserção finalizada!!!');
    }
  }

  Future<void> consultarUsuarios() async {
    
    try {
      
      // Busca uma lista de objetos
      List<Usuario> usuarios = await banco.lista();

      if (!mounted) return;
      
      String texto = ''; // Armazena o resultado da consulta

      // Percorre os usuários encotrados.
      for (var usuario in usuarios) {
        texto += '${usuario.id} - ${usuario.nome}\n';
        texto += '${usuario.email}\n\n';
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

    // Remove espaço externo e tentar converte o ID para int
    // Caso não seja possível a conversão, retorna null
    int? codigo = int.tryParse(id.text.trim());

    // Valida se o ID é um número inteiro e maior que zero
    if (codigo == null || !ValidadorUsario.validaId(codigo)) {
      
      setState(() {
        resultado = 'Informe um ID válido!!!';
      });

      return; // Encerra o método se o ID for inválido
    }

    // Cria um objeto Usuario com os novos dados
    Usuario usuario = Usuario(
      
      id: codigo, // ID do usuário que será alterado
      nome: nome.text.trim(), //Remove espaços externos
      email: email.text.trim().toLowerCase(), // Padroniza o e-mail 
    );

    // Valida o nome e e-mail
    String? erroValidacao = ValidadorUsario.validaUsuario(usuario);

    // Verifica se existe algum erro de validação
    if (erroValidacao != null) {
      setState(() {
        resultado = erroValidacao; // Exibe a mensagem de erro
      });
      return; //Encerra o método sem alterar o banco
    }
    
    try { 

        // Executa a alteração no SQLite
        int quantidade = await banco.alterar(codigo, nome.text, email.text);

        if (!mounted) return;

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
          resultado =  'Informe um ID válido!!!';
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

  // Pesquisa de um usuário pelo ID
  Future<void> buscarUsuario() async {

    // Converter o ID digitado para inteiro
    int? codigo = int.tryParse(id.text.trim());

    if (!ValidadorUsario.validaId(codigo)) {
      setState(() {
          resultado = 'Informe um ID válido!!!';
      });
      return;
    }

    try {

      // Consulta o usuário no SQLite
      Usuario? usuario = await banco.buscaPorId(codigo!);

      if (!mounted) return;

      // Verifica se encontrou o resultado
      if (usuario == null) {
        setState(() {
          resultado = 'Usuário não encontrado!!!';
        });
        return;
      }

      // Exibe os dados do usuário encontrado
      setState(() {
        resultado = '${usuario.id} - ${usuario.nome}\n'
                    '${usuario.email}';

      });
    } catch (erro) {
      if (!mounted) return;
      
      setState(() {
        resultado = 'Não foi possível buscar o ID';
      });
    } finally {
      print('Operação de pesquisa finalizada');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Cadastro de usuários'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        
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
            decoration: const InputDecoration(
              labelText: 'Nome',
            ),
          ),

          // Campo para digitar o e-mail.
          TextField(
            controller: email,
            decoration: InputDecoration(
              labelText: 'E-mail',
            ),
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

        // Botão para Excluir (Ainda sem funcionalidade)
        ElevatedButton(
          onPressed: buscarUsuario,
           child: const Text('Busca por ID'),
        ),

        const SizedBox(height: 20),

          // Espaço reservado para exibir os resultados
          Expanded(
            child: SingleChildScrollView(
              child: Text(resultado),
            ),  
          ),
         ],
        ),
      ),
    );
  }
}