class UsuarioModel {
  String? id;
  String? nome;
  String? email;
  String? urlFoto;
  bool? ativo;
  String? senha;
  String? token;
  String? tipoToken;
  String? expiraEm;
  String? criadoEm;
  String? atualizadoEm;

  UsuarioModel({
    this.id,
    this.nome,
    this.email,
    this.urlFoto,
    this.ativo,
    this.senha,
    this.token,
    this.tipoToken,
    this.expiraEm,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory UsuarioModel.empty() {
    return UsuarioModel(
      id: null,
      nome: '',
      email: '',
      urlFoto: null,
      ativo: null,
      senha: null,
      token: null,
      tipoToken: null,
      expiraEm: null,
      criadoEm: null,
      atualizadoEm: null,
    );
  }

  UsuarioModel.fromMap(Map<String, dynamic> json) {
    id = (json['id_usuario'] ?? json['id'])?.toString();
    nome = json['nome']?.toString();
    email = json['email']?.toString();
    urlFoto = (json['url_foto'] ?? json['foto'] ?? json['photo_url'])?.toString();
    if (urlFoto != null && urlFoto!.trim().isEmpty) urlFoto = null;
    ativo = json['ativo'] is bool ? json['ativo'] as bool : null;
    senha = json['senha']?.toString();
    token = json['token']?.toString();
    tipoToken = json['tipo_token']?.toString();
    expiraEm = json['expira_em']?.toString();
    criadoEm = json['criado_em']?.toString();
    atualizadoEm = json['atualizado_em']?.toString();
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome': nome ?? '',
      'email': email ?? '',
      'senha': senha ?? '',
    };
  }

  Map<String, dynamic> toJsonEntrar() {
    return {
      'email': email ?? '',
      'senha': senha ?? '',
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'url_foto': urlFoto,
      'ativo': ativo,
      'token': token,
      'tipo_token': tipoToken,
      'expira_em': expiraEm,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }
}
