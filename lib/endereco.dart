class Endereco {

  int? id; //Identificador do endereço (PK)
  int usuarioId; // ID do usuário (FK)
  String cep; // CEP somente com números (8 dígitos)
  String logradouro; // Nome da rua, alameda, avenida ou similar.
  int numero; // Número do imovel na rua
  String cidade; //Cidade do endereço

  //Construtor da classe endereço
  Endereco({
    this.id,
    required this.usuarioId, //Id gerado automaticamente na tabela usuario
    required this.cep, // CEP obrigatório
    required this.logradouro, //Logradouro obrigatorio
    required this.numero, // Número obrigatório
    required this.cidade //Cidade obrigatória
  });

  //Converte o objeto Endereco em um MAP
  Map<String, Object?> paraMap() {
    return {
      'usuario_id': usuarioId,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'cidade': cidade,
    };
  }

  static Endereco doMap(Map<String, Object?> dados) {
    return Endereco(
      id: dados['id'] as int,
      usuarioId: dados['usuario_id'] as int,
      cep: (dados['cep'] ?? '') as String,
      logradouro: dados['logradouro'] as String,
      numero: dados['numero'] as int,
      cidade: dados['cidade'] as String,
    );
  }

}