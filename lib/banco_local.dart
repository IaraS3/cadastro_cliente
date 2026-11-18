import 'package:sqflite/sqflite.dart'; // Biblioteca do SQLite
import 'package:path/path.dart'; // Manipula caminho
import 'usuario.dart'; // Importa a classe Usuario

class BancoLocal {

  Database? banco; // Guardando a conexão com o BD

  Future<Database> abrirBanco() async {

    // Reutiliza a conexão se o banco já estiver aberto.
    if (banco != null && banco!.isOpen) {
      return banco!;
    }

    String pasta = await getDatabasesPath(); // Pasta do banco de dados
    String arquivo = join(pasta, 'cadastro.db'); // Nome e local do arquivo
    
    banco = await openDatabase(
      arquivo, // Caminho completo do BD
      version: 1, // Versão Inicial do BD

      onCreate: (db, version) async {
          await db.execute('''CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE
          )
         ''');
        },
      );
      
    return banco!; //Retorna a conexão aberta
  }

  // Cadastro de um novo usuário
  Future<void> cadastrar(Usuario usuario) async {

    final db = await abrirBanco();

        await db.insert('usuarios', usuario.paraMap(),);
  }

  // Consulta todos os usuários cadastrados
  Future<List<Usuario>> lista() async {

    final db = await abrirBanco(); // Obtém o banco

    // Consulta os registro na tabela usuários.
    final registros = await db.query('usuarios');

    // Cria uma lista vazia de objetos (tabela usuarios.)
    List<Usuario> usuarios = [];

    // Percorre os registros retornados pelo SQLite.
    for (var registro in registros) {
      // Converter o MAP de um objeto
      Usuario usuario = Usuario.doMap(registro);

      // Adiciona o objeto na lista
      usuarios.add(usuario);
    }

    return usuarios;
  }


  // Altera o nome e o e-mail de um usuário
  Future<int> alterar(int id, String nome, String email) async {

    final db = await abrirBanco(); // Obtém o banco

    return await db.update(
      'usuarios', // Tabela que será alterada
      {
        'nome':nome, // Novo Nome
        'email': email // Novo e-mail
      }, 
      where: 'id = ?', // Condição WHERE
      whereArgs: [id], // Valor utilizado na condição
    );
  }

  // Exclui um usuário pelo ID
  Future<int> excluir(int id) async {

    final db = await abrirBanco(); // Obtém banco

    return await db.delete(
      'usuarios', // Tabela utilizada
      where: 'id = ?', // Condição WHERE
      whereArgs: [id], // ID do usuário.
    );
  }

  // Pesquisa de um usuário pelo ID
  Future<Usuario?> buscaPorId(int id) async {
    
    // Abre o BD
    final db = await abrirBanco();

    // Consulta o registro
    // exemplo: select * from usuarios where id = ???
    final registros = await db.query(
          'usuarios', 
          where: 'id = ?',
          whereArgs: [id],
         );
      
      // Verificação de encontrou algum registro
      if (registros.isEmpty) {
        return null;
      }
      
      // Converter o registro encontrado em um objeto para manipução
      return Usuario.doMap(registros.first);
  }
}
 