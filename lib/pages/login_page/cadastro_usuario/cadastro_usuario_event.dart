abstract class CadastroUsuarioEvent {}

class CadastroUsuarioSaveEvent extends CadastroUsuarioEvent {
  final String nome;
  final String email;
  final String senha;

  CadastroUsuarioSaveEvent({
    required this.nome,
    required this.email,
    required this.senha,
  });
}
