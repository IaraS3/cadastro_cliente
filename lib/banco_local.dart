import 'package:sqflite/sqflite.dart'; // Biblioteca do SQLite
import 'package:path/path.dart'; //Manipula caminho

class BancoLocal {
  Database? banco; //Guardando a conexão com o BD

  Future<Database> abrirBanco() async {
    // Reutiliza a conexão se o banco já estiver aberto.
    if (banco != null && banco!.isOpen) {
      return banco!;
    }

    String pasta = await getDatabasesPath(); //pasta do banco de dados
    String arquivo = join(pasta, 'cadastro.db'); //Nome e local do arquivo

    banco = await openDatabase(
      arquivo, // Caminho completo do BD
      version: 1, //Versão inicial do BD

      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE
        )''');
      },
    );
    return banco!; //Retorna conexão aberta
  }

  // Cadastro de um novo usuario
  Future<void> cadastrar(String nome, String email) async {
    final db = await abrirBanco();

    await db.insert('usuarios', {'nome': nome, 'email': email});
  }

  //Consulta todos os usuários cadastrados
  // Future<List<Map<String, Object?>>> listar() async{
  Future<List> listar() async {
    final db = await abrirBanco();
    return await db.query('usuarios');
  }

  // Alterar o nome e o email de um usuario
  Future<int> alterar(int id, String nome, String email) async {
    final db = await abrirBanco();
    return await db.update(
      'usuarios', //tabela que será alterada
      {'nome': nome, 'email': email}, //novos dados
      where: 'id = ?', //condição de alteração
      whereArgs: [id],
    );
  }

  //Excluir um usuario pelo id
  Future<int> excluir(int id) async {
    final db = await abrirBanco();
    return await db.delete(
      'usuarios', //tabela que será excluída
      where: 'id = ?', //condição de exclusão
      whereArgs: [id], //id do usuário
    );
  }
}
