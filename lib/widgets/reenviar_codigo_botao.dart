import 'dart:async';

import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, appTextButton;

/// Botão de reenvio com contagem regressiva (desabilitado enquanto conta).
class ReenviarCodigoBotao extends StatefulWidget {
  final Future<void> Function() onReenviar;
  final Duration intervalo;
  final bool iniciarAoMontar;

  const ReenviarCodigoBotao({
    super.key,
    required this.onReenviar,
    this.intervalo = const Duration(minutes: 5),
    this.iniciarAoMontar = true,
  });

  @override
  State<ReenviarCodigoBotao> createState() => _ReenviarCodigoBotaoState();
}

class _ReenviarCodigoBotaoState extends State<ReenviarCodigoBotao> {
  Timer? _timer;
  int _segundosRestantes = 0;
  bool _carregando = false;

  bool get _bloqueado => _segundosRestantes > 0 || _carregando;

  @override
  void initState() {
    super.initState();
    if (widget.iniciarAoMontar) {
      _iniciarContagem();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarContagem() {
    _timer?.cancel();
    setState(() => _segundosRestantes = widget.intervalo.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_segundosRestantes <= 1) {
        timer.cancel();
        setState(() => _segundosRestantes = 0);
        return;
      }
      setState(() => _segundosRestantes -= 1);
    });
  }

  String _formatar(int totalSegundos) {
    final minutos = totalSegundos ~/ 60;
    final segundos = totalSegundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  Future<void> _aoTocar() async {
    if (_bloqueado) return;
    setState(() => _carregando = true);
    try {
      await widget.onReenviar();
      if (!mounted) return;
      _iniciarContagem();
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Center(child: appLoadingDinix(size: 22));
    }

    final ativo = !_bloqueado;
    final texto = ativo
        ? 'Reenviar código'
        : 'Reenviar em ${_formatar(_segundosRestantes)}';

    return Opacity(
      opacity: ativo ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !ativo,
        child: appTextButton(
          text: texto,
          color: DinixColors.primary,
          onTap: _aoTocar,
        ),
      ),
    );
  }
}
