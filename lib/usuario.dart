class Usuario {
  int? id; // Identificado do usuário no BD
  String nome; // Nome do usuário
  String email; // E-mail do usuário

  Usuario({
    this.id, // Opcional, pois SQLite pode gerar o ID automáticamente
    required this.nome, // Nome obrigatório
    required this.email, // E-mail Obrigatório
  });

  // Converte o objeto em MAP
  Map<String, Object?> paraMap() {
    return {'nome': nome, 'email': email};
  }

  // Converte de um MAP em Objeto
  static Usuario doMap(Map<String, Object?> dados) {
    return Usuario(
      id: dados['id'] as int,
      nome: dados['nome'] as String,
      email: dados['email'] as String,
    );
  }
}
