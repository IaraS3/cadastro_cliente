import 'package:sqflite/sqflite.dart'; // Biblioteca do SQLite
import 'package:path/path.dart'; // Manipula caminho

import 'usuario.dart'; // Importa a classe Usuario
import 'endereco.dart'; //Importa a classe Endereco

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
      version: 2, // Versão Atual do BD
      //Habilitar a verificação de chave estrangeira
      onConfigure: (db) async {
        await db.execute('PRAGMA foreing_keys = ON');
      },

      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE
          )
         ''');

        //Cria a tabela enderecos
        await db.execute('''
            CREATE TABLE enderecos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              usuario_id INTEGER NOT NULL,
              logadouro TEXT NOT NULL,
              numero INTEGER NOT NULL,
              cidade TEXT NOT NULL,
              FOREING KEY  (usuario) REFERENCES usuarios(id)
            )
          ''');
      },

      // ONUPGRAD: Atualiza o banco da versão 1 para a 2.
      onUpgrade: (db, versaoAntiga, versaoNova) async {
        
        //Verifica se o banco ainda está na versão 1
        if (versaoAntiga < 2) {
          //Crio a tabela endereço sem apagar a tabela usuario ()
          await db.execute('''
              CREATE TABLE enderecos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                usuario_id INTEGER NOT NULL,
                logradouro TEXT NOT NULL,
                numero INTEGER NOT NULL,
                cidade TEXT NOT NULL,
                FOREING KEY  (usuario) REFERENCES usuarios(id)
              )
            ''');
        }
      },
    );

    return banco!; //Retorna a conexão aberta
  }

  // Cadastro de um novo usuário
  Future<void> cadastrar(Usuario usuario) async {
    final db = await abrirBanco();

    await db.insert('usuarios', usuario.paraMap());
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
        'nome': nome, // Novo Nome
        'email': email, // Novo e-mail
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

  //Cadastrar um endereço relacionado a um usuario
  Future<void> cadastrarEndereco(Endereco endereco) async {
    final db = await abrirBanco(); //Obtém o BD

    //Insere o endereço utilizando o objeto convertido em MAP
    await db.insert(
      'enderecos',
      endereco.paraMap(), //Converte o objeto Endereço em MAP
    );
  }

  //Consultar todos os endereços cadastrados
  Future<List<Endereco>> listarEnderecos() async {
    final db = await abrirBanco(); //Obtém o db

    //Consulta os registros da tabela endereços
    final registros = await db.query('enderecos');

    //Cria uma lista vazia de objetos
    List<Endereco> enderecos = [];

    //Percore os registros retornados pelo SQLite
    for (var registro in registros) {
      //Converte o MAP em um objeto Endereco
      Endereco endereco = Endereco.doMap(registro);

      //Adiciona o objeto na lista
      enderecos.add(endereco);
    }
    //Retorna todos os endereços cadastrados
    return enderecos;
  }

  //Consulta de usuários e seus respectivos endereços
  Future<List<Map<String, Object?>>> consultarUsuarioEndereco() async {
    final db = await abrirBanco(); // o btém o BD

    //Executa um SELECT relacionado as duas tabelas
    final registros = await db.rawQuery('''sql
      SELECT
        usuarios.id AS usuario_id,
        usuarios.nome,
        usuarios.email,
        enderecos.id AS endereco_id,
        enderecos.logradouro,
        enderecos.numero,
        enderecos.cidade
      FROM usuarios
      INNER JOIN enderecos
        ON usuarios.id = enderecos.usuario_id
      ORDER BY usuarios.nome
    ''');

    //Retorna os registros encontrados
    return registros;
  }
}
