
class Usuario {
  int? id; //identificador do usuario no BD
  String nome; //nome do usuário
  String email; // E-mail do usuário

  Usuario({
    this.id, // Opcional, pois o SQLite pode gerar o id automaticamente
    required this.nome, // Nome obrigatório
    required this.email // E-mail obrigatório
  });
}