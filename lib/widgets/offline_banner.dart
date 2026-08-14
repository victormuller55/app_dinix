import 'dart:async';

import 'package:app_dinix/function/show_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

bool _estaOffline(List<ConnectivityResult> resultados) {
  if (resultados.isEmpty) return true;
  return resultados.every((r) => r == ConnectivityResult.none);
}

/// Monitora a conexão e exibe snackbar ao perder/recuperar a internet.
class OfflineBannerHost extends StatefulWidget {
  final Widget child;

  const OfflineBannerHost({super.key, required this.child});

  @override
  State<OfflineBannerHost> createState() => _OfflineBannerHostState();
}

class _OfflineBannerHostState extends State<OfflineBannerHost> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool? _offline;

  @override
  void initState() {
    super.initState();
    _verificar();
    _subscription = Connectivity().onConnectivityChanged.listen(_atualizar);
  }

  Future<void> _verificar() async {
    final resultados = await Connectivity().checkConnectivity();
    if (!mounted) return;
    _atualizar(resultados, avisoInicial: true);
  }

  void _atualizar(
    List<ConnectivityResult> resultados, {
    bool avisoInicial = false,
  }) {
    final offline = _estaOffline(resultados);
    final mudou = _offline != null && offline != _offline;
    _offline = offline;

    if (!mounted) return;
    if (avisoInicial && offline) {
      showToastWarning(message: 'Sem conexão com a internet');
      return;
    }
    if (!mudou) return;

    if (offline) {
      showToastWarning(message: 'Sem conexão com a internet');
    } else {
      showToastSuccess(message: 'Conexão restabelecida');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
