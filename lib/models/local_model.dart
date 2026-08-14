class LocalModel {
  String? id;
  String? nome;
  String? descricao;
  String? endereco;
  String? cidade;
  String? estado;
  double? latitude;
  double? longitude;

  LocalModel({
    this.id,
    this.nome,
    this.descricao,
    this.endereco,
    this.cidade,
    this.estado,
    this.latitude,
    this.longitude,
  });

  factory LocalModel.empty() => LocalModel(nome: '');

  LocalModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    nome = json['nome']?.toString();
    descricao = json['descricao']?.toString();
    endereco = json['endereco']?.toString();
    cidade = json['cidade']?.toString();
    estado = json['estado']?.toString();
    latitude = json['latitude'] is num ? (json['latitude'] as num).toDouble() : null;
    longitude = json['longitude'] is num ? (json['longitude'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome': nome ?? '',
      'descricao': _opcional(descricao),
      'endereco': _opcional(endereco),
      'cidade': _opcional(cidade),
      'estado': _opcional(estado),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, dynamic> toMap() => toJsonCadastro()
    ..['id'] = id;

  String? _opcional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
