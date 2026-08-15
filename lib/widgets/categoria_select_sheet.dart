import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/categoria_icone.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

Future<CategoriaModel?> showCategoriaSelectSheet({
  required BuildContext context,
  required List<CategoriaModel> categorias,
  CategoriaModel? selected,
  String title = 'Categoria',
}) {
  return showModalBottomSheet<CategoriaModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: DinixColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (ctx) => _CategoriaSelectSheet(
      title: title,
      categorias: categorias,
      selected: selected,
    ),
  );
}

class _CategoriaSelectSheet extends StatefulWidget {
  final String title;
  final List<CategoriaModel> categorias;
  final CategoriaModel? selected;

  const _CategoriaSelectSheet({
    required this.title,
    required this.categorias,
    this.selected,
  });

  @override
  State<_CategoriaSelectSheet> createState() => _CategoriaSelectSheetState();
}

class _CategoriaSelectSheetState extends State<_CategoriaSelectSheet> {
  late final Map<String, CategoriaModel> _porId;
  late final List<CategoriaModel> _pais;
  late final Map<String, List<CategoriaModel>> _filhosPorPai;
  late final List<CategoriaModel> _orfaos;

  CategoriaModel? _grupoAberto;

  @override
  void initState() {
    super.initState();
    _porId = {
      for (final c in widget.categorias)
        if (c.id != null && c.id!.isNotEmpty) c.id!: c,
    };

    _filhosPorPai = {};
    _orfaos = [];
    final pais = <CategoriaModel>[];

    for (final c in widget.categorias) {
      final idPai = c.idCategoriaPai?.trim() ?? '';
      if (idPai.isEmpty) {
        pais.add(c);
        continue;
      }
      if (_porId.containsKey(idPai)) {
        _filhosPorPai.putIfAbsent(idPai, () => []).add(c);
      } else {
        _orfaos.add(c);
      }
    }

    int byNome(CategoriaModel a, CategoriaModel b) =>
        (a.nome ?? '').toLowerCase().compareTo((b.nome ?? '').toLowerCase());

    pais.sort(byNome);
    for (final lista in _filhosPorPai.values) {
      lista.sort(byNome);
    }
    _orfaos.sort(byNome);
    _pais = pais;

    final selecionada = widget.selected;
    final idPaiSelecionado = selecionada?.idCategoriaPai?.trim() ?? '';
    if (selecionada != null &&
        idPaiSelecionado.isNotEmpty &&
        _filhosPorPai.containsKey(idPaiSelecionado)) {
      _grupoAberto = _porId[idPaiSelecionado];
    }
  }

  List<CategoriaModel> _filhosDe(CategoriaModel pai) {
    final id = pai.id;
    if (id == null || id.isEmpty) return const [];
    return _filhosPorPai[id] ?? const [];
  }

  bool _estaSelecionado(CategoriaModel item) {
    final sel = widget.selected;
    if (sel == null) return false;
    if (sel.id != null && item.id != null) return sel.id == item.id;
    return identical(sel, item);
  }

  void _abrirGrupo(CategoriaModel pai) {
    final filhos = _filhosDe(pai);
    if (filhos.isEmpty) {
      Navigator.pop(context, pai);
      return;
    }
    setState(() => _grupoAberto = pai);
  }

  Widget _handle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey700,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    final grupo = _grupoAberto;
    if (grupo == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: appText(
            widget.title,
            bold: true,
            color: DinixColors.textPrimary,
            fontSize: AppFontSizes.normal,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _grupoAberto = null),
            icon: Icon(Phosphor.caretLeft, color: DinixColors.textPrimary),
            tooltip: 'Voltar',
          ),
          Expanded(
            child: appText(
              grupo.nome ?? widget.title,
              bold: true,
              color: DinixColors.textPrimary,
              fontSize: AppFontSizes.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(CategoriaModel item, {VoidCallback? onTap}) {
    final selecionado = _estaSelecionado(item);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context, item),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            color: DinixColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selecionado
                  ? DinixColors.primary
                  : AppColors.grey800.withValues(alpha: 0.9),
              width: selecionado ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconeDaCategoria(item, categoriasPorId: _porId),
                  color: DinixColors.primary,
                  size: 26,
                ),
                appSizedBox(height: 8),
                appText(
                  item.nome ?? '',
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.verySmall,
                  bold: selecionado,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(List<CategoriaModel> items, {bool abrirGrupo = false}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: appText(
            'Nenhuma categoria disponível.',
            color: AppColors.grey400,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return _card(
          item,
          onTap: abrirGrupo ? () => _abrirGrupo(item) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final grupo = _grupoAberto;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            _cabecalho(),
            Flexible(
              child: grupo == null
                  ? _grid([..._pais, ..._orfaos], abrirGrupo: true)
                  : _grid(_filhosDe(grupo)),
            ),
          ],
        ),
      ),
    );
  }
}
