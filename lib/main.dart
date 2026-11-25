import 'package:cadastro_cliente/banco_local.dart';
import 'package:cadastro_cliente/usuario.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Filtro de digitação (CEP)
import 'package:sqflite/sqflite.dart'; // databaseFactory
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // SQLite no Chrome
import 'validador_usuario.dart'; // Validador
import 'endereco.dart'; // Classe Endereco

void main() {
  // No Chrome o SQLite precisa da fábrica web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaInicial(),
    );
  }
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final banco = BancoLocal();

  // Controladores do usuário
  final id = TextEditingController();
  final nome = TextEditingController();
  final email = TextEditingController();

  // Controladores do endereço
  final cep = TextEditingController();
  final logradouro = TextEditingController();
  final numero = TextEditingController();
  final cidade = TextEditingController();

  String resultado = '';

  // Exibe o CEP no formato 00000-000
  String _formatarCep(Object? valor) {
    final digitos = (valor ?? '').toString().replaceAll(RegExp(r'\D'), '');
    if (digitos.length == 8) {
      return '${digitos.substring(0, 5)}-${digitos.substring(5)}';
    }
    return digitos;
  }

  // ---------- Auxiliares ----------

  void _mostrar(String mensagem) {
    if (!mounted) return;
    setState(() {
      resultado = mensagem;
    });
  }

  // Lê o ID da tela. Retorna null se for inválido.
  int? _lerId() {
    final codigo = int.tryParse(id.text.trim());
    if (codigo == null || !ValidadorUsuario.validaId(codigo)) {
      return null;
    }
    return codigo;
  }

  // Monta o usuário com os dados tratados da tela
  Usuario _montarUsuario({int? codigo}) {
    return Usuario(
      id: codigo,
      nome: nome.text.trim(),
      email: email.text.trim().toLowerCase(),
    );
  }

  void _limparCampos() {
    id.clear();
    nome.clear();
    email.clear();
    cep.clear();
    logradouro.clear();
    numero.clear();
    cidade.clear();
  }

  // ---------- Cadastro (usuário + endereço) ----------

  Future<void> cadastrarUsuario() async {
    final usuario = _montarUsuario();

    // 1) Valida usuário
    final erroValidacao = ValidadorUsuario.validaUsuario(usuario);
    if (erroValidacao != null) {
      _mostrar(erroValidacao);
      return;
    }

    // 2) Valida endereço (antes de gravar qualquer coisa)
    final cepDigitos = cep.text.replaceAll(RegExp(r'\D'), '');
    final rua = logradouro.text.trim();
    final numeroEnd = int.tryParse(numero.text.trim());
    final cid = cidade.text.trim();

    if (cepDigitos.length != 8) {
      _mostrar('Informe um CEP válido com 8 números!!!');
      return;
    }
    if (rua.isEmpty) {
      _mostrar('Informe o logradouro!!!');
      return;
    }
    if (numeroEnd == null || numeroEnd <= 0) {
      _mostrar('Informe um número válido!!!');
      return;
    }
    if (cid.isEmpty) {
      _mostrar('Informe a cidade!!!');
      return;
    }

    try {
      // 3) Grava o usuário
      await banco.cadastrar(usuario);

      // 4) Descobre o ID do usuário recém-criado (o maior ID da tabela)
      final usuarios = await banco.lista();
      final novo = usuarios.reduce((a, b) => (a.id ?? 0) > (b.id ?? 0) ? a : b);

      // 5) Grava o endereço ligado a esse usuário
      final endereco = Endereco(
        usuarioId: novo.id!,
        cep: cepDigitos,
        logradouro: rua,
        numero: numeroEnd,
        cidade: cid,
      );
      await banco.cadastrarEndereco(endereco);

      _limparCampos();

      _mostrar('Cadastro realizado com SUCESSO!!!\n\n'
          'ID: ${novo.id}\n'
          'Nome: ${novo.nome}\n'
          'E-mail: ${novo.email}\n'
          'CEP: ${_formatarCep(cepDigitos)}\n'
          'Logradouro: ${endereco.logradouro}\n'
          'Número: ${endereco.numero}\n'
          'Cidade: ${endereco.cidade}');
    } catch (erro) {
      debugPrint('Erro ao cadastrar: $erro');
      _mostrar('Não foi possível concluir o cadastro');
    } finally {
      debugPrint('Operação de cadastro finalizada!!!');
    }
  }

  // ---------- Consultas ----------

  // Lista usuários com seus endereços
  Future<void> consultarUsuarios() async {
    try {
      final registros = await banco.consultarUsuarioEndereco();

      if (registros.isEmpty) {
        _mostrar('Nenhum usuário cadastrado');
        return;
      }

      final texto = StringBuffer();
      for (final registro in registros) {
        texto.writeln('Nome: ${registro['nome']}');
        texto.writeln('E-mail: ${registro['email']}');
        texto.writeln('CEP: ${_formatarCep(registro['cep'])}');
        texto.writeln('Logradouro: ${registro['logradouro']}');
        texto.writeln('Número: ${registro['numero']}');
        texto.writeln('Cidade: ${registro['cidade']}\n');
      }

      _mostrar(texto.toString());
    } catch (erro) {
      debugPrint('Erro ao consultar: $erro');
      _mostrar('Não foi possível consultar os usuários');
    } finally {
      debugPrint('Operação de consulta finalizada!!!');
    }
  }

  Future<void> buscarUsuario() async {
    final codigo = _lerId();
    if (codigo == null) {
      _mostrar('Informe um ID válido!!!');
      return;
    }

    try {
      final usuario = await banco.buscaPorId(codigo);

      if (usuario == null) {
        _mostrar('Usuário não encontrado!!!');
        return;
      }

      _mostrar('${usuario.id} - ${usuario.nome}\n${usuario.email}');
    } catch (erro) {
      debugPrint('Erro ao buscar: $erro');
      _mostrar('Não foi possível buscar o ID');
    } finally {
      debugPrint('Operação de pesquisa finalizada');
    }
  }

  // ---------- Alterar e excluir ----------

  Future<void> alterarUsuario() async {
    final codigo = _lerId();
    if (codigo == null) {
      _mostrar('Informe um ID válido!!!');
      return;
    }

    final usuario = _montarUsuario(codigo: codigo);

    final erroValidacao = ValidadorUsuario.validaUsuario(usuario);
    if (erroValidacao != null) {
      _mostrar(erroValidacao);
      return;
    }

    try {
      final quantidade =
          await banco.alterar(codigo, usuario.nome, usuario.email);

      id.clear();
      nome.clear();
      email.clear();

      _mostrar(quantidade > 0
          ? 'Usuário alterado com SUCESSO!!!'
          : 'Usuário não encontrado!!!');
    } catch (erro) {
      debugPrint('Erro ao alterar: $erro');
      _mostrar('Não foi possível alterar o usuário!!!');
    }
  }

  Future<void> excluirUsuario() async {
    final codigo = _lerId();
    if (codigo == null) {
      _mostrar('Informe um ID válido!!!');
      return;
    }

    try {
      final quantidade = await banco.excluir(codigo);

      id.clear();

      _mostrar(quantidade > 0
          ? 'Usuário excluído com sucesso!!!'
          : 'Usuário não encontrado!!!');
    } catch (erro) {
      debugPrint('Erro ao excluir: $erro');
      _mostrar('Não foi possível excluir o usuário');
    }
  }

  // ---------- Ciclo de vida ----------

  @override
  void dispose() {
    id.dispose();
    nome.dispose();
    email.dispose();
    cep.dispose();
    logradouro.dispose();
    numero.dispose();
    cidade.dispose();
    super.dispose();
  }

  // ---------- Interface ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de usuários')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: id,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID (somente para alterar, excluir ou buscar)',
              ),
            ),
            TextField(
              controller: nome,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: cep,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // só números
                LengthLimitingTextInputFormatter(8), // máximo 8 dígitos
              ],
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: 'Somente números. Ex.: 09210000',
              ),
            ),
            TextField(
              controller: logradouro,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Logradouro',
                hintText: 'Ex.: Av. Paulista, Rua das Flores, Estrada do Mar',
              ),
            ),
            TextField(
              controller: numero,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Número'),
            ),
            TextField(
              controller: cidade,
              decoration: const InputDecoration(labelText: 'Cidade'),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: cadastrarUsuario,
                  child: const Text('Cadastrar'),
                ),
                ElevatedButton(
                  onPressed: consultarUsuarios,
                  child: const Text('Consultar usuários'),
                ),
                ElevatedButton(
                  onPressed: alterarUsuario,
                  child: const Text('Alterar usuário'),
                ),
                ElevatedButton(
                  onPressed: excluirUsuario,
                  child: const Text('Excluir usuário'),
                ),
                ElevatedButton(
                  onPressed: buscarUsuario,
                  child: const Text('Buscar por ID'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Resultado
            Text(resultado),
          ],
        ),
      ),
    );
  }
}