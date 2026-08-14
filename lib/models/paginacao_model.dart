class PaginacaoModel<T> {
  final List<T> itens;
  final int numPag;
  final int maxPag;
  final int maxItens;
  final int itensPag;

  const PaginacaoModel({
    required this.itens,
    required this.numPag,
    required this.maxPag,
    required this.maxItens,
    required this.itensPag,
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  bool get vazia => itens.isEmpty || maxItens == 0;

  factory PaginacaoModel.fromMap(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawItens = json['itens'];
    final itens = <T>[];
    if (rawItens is List) {
      for (final item in rawItens) {
        if (item is Map) {
          itens.add(fromItem(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PaginacaoModel<T>(
      itens: itens,
      numPag: _asInt(json['num_pag'] ?? json['num_pagina'], fallback: 1),
      maxPag: _asInt(json['max_pag'] ?? json['max_paginas'], fallback: itens.isEmpty ? 0 : 1),
      maxItens: _asInt(json['max_itens'], fallback: itens.length),
      itensPag: _asInt(json['itens_pag'] ?? json['num_itens'], fallback: itens.length),
    );
  }

  Map<String, dynamic> toCacheMap(Map<String, dynamic> Function(T) toItem) {
    return {
      'itens': itens.map(toItem).toList(),
      'num_pag': numPag,
      'max_pag': maxPag,
      'max_itens': maxItens,
      'itens_pag': itensPag,
    };
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value == null) return fallback;
    return int.tryParse(value.toString()) ?? fallback;
  }
}
