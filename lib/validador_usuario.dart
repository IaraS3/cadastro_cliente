import 'usuario.dart'; // Import Classe Usuario

// Classe responsável pelas validações do usuário
class ValidadorUsuario {
  
  // Valida o nome do usuário
  static bool validarNome(String nome) {
    // Remover os espaços  do início e do final.
    String nomeTratado = nome.trim();

    // Verifica se o nome possui o tamanho entre 3 e 60
    return nomeTratado.length >= 3 &&
           nomeTratado.length <= 60;
  }

  // Verifica de o nome possui números
  static bool contemNumeros(String nome) {

    // Define um padrão que identifica números de 0 a 9.
    RegExp regra = RegExp(r'[0-9]');

    // Retorna true caso encontre algum número.
    return regra.hasMatch(nome);
  }

  // Verifica se o nome possui somente caracteres permitidos.
  // Permitir letras maiúsculas, minúsculas e acentuadas.
  // Permitir espaços entre as palavras.
  static bool validaCaracteresNome(String nome) {

    // Permite letras maiúsculas e minúsculas
    // letras acentuadas e espaços.
    RegExp regra = RegExp(
      r'^[a-zA-ZÀ-ÿ]+( [a-zA-ZÀ-ÿ]+)*$',
      );

    // Verifica se o nome corresponde ao padrão
    return regra.hasMatch(nome.trim());
  }

  // Verifica se o usuário informou pelo menos dois nomes
  static bool validaNomeCompleto(String nome) {

    // Remove os espaços do início e do final
    String nomeTratado = nome.trim();

    // Verifica se existe um espaço entre as palavras
    return nomeTratado.contains(' ');
  }


  // Valida o formato do e-mail
  static bool validaEmail(String email) {

    // Define o padrão de e-mail
    RegExp regra = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$',);

    return regra.hasMatch(email.trim());
  }

  // Valida o OD do usuário.
  static bool validaId(int? id) {
    
    // o ID deve existir e ser maior que zero.
    return id != null && id > 0;
  }

  // Valida os dados de um objeto Usuario
  static String? validaUsuario(Usuario usuario) {

    // Remove os espaço externo do nome
    String nome = usuario.nome.trim();
    String email = usuario.email.trim();
   
    // Verifica o nome
    if (!validarNome(usuario.nome)) {

      // Verica se o nome possui menos de 3 caracteres
      if (nome.length < 3) {
        return 'O nome deve possuir 3 caracteres!!!';
      }

      return 'O nome deve possuir no máximo 60 caracteres!!!';
    }

    // Verifica se o nome contém números
    if (contemNumeros(nome)) {
      return 'O nome não pode conter números';
    }

    // Verifica se o nome contém caractestes inválidos
    if (!validaCaracteresNome(nome)) {

      return ('O nome contém caracteres inválidos!!!');
    }

    // Verifica se foi informado o nome completo
    if (!validaNomeCompleto(nome)) {
      
      return 'Informe o nome completo!!!';
    }

    // Verifica se o e-mail tem mais de 100 caracteres
    if (email.length > 100) {
      return 'O e-mail deve possuir no máximo 100 caracteres!!!';
    }

    // Verifica o e-mail
    if (!validaEmail(usuario.email)) {
      return 'Informe um e-mail válido!!!';
    }
    
    // Retorna null quando não existirem erros
    return null;
  }
}