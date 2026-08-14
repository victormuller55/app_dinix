class CategoriaModel {
  String? id;
  String? nome;
  String? descricao;
  String? icone;
  String? tipo;
  String? idCategoriaPai;
  bool? padraoSistema;

  CategoriaModel({
    this.id,
    this.nome,
    this.descricao,
    this.icone,
    this.tipo,
    this.idCategoriaPai,
    this.padraoSistema,
  });

  factory CategoriaModel.empty() => CategoriaModel(nome: '', tipo: 'despesa');

  CategoriaModel.fromMap(Map<String, dynamic> json) {
    id = json['id']?.toString();
    nome = json['nome']?.toString();
    descricao = json['descricao']?.toString();
    icone = json['icone']?.toString();
    tipo = json['tipo']?.toString();
    idCategoriaPai = json['id_categoria_pai']?.toString();
    padraoSistema = json['padrao_sistema'] is bool ? json['padrao_sistema'] as bool : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'icone': icone,
      'tipo': tipo,
      'id_categoria_pai': idCategoriaPai,
      'padrao_sistema': padraoSistema,
    };
  }
}
