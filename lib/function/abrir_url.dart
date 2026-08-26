import 'package:app_dinix/function/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> abrirUrlExterna(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    showToastError(message: 'Não foi possível abrir o link');
    return;
  }
  try {
    final aberto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!aberto) {
      showToastError(message: 'Não foi possível abrir o link');
    }
  } catch (_) {
    showToastError(message: 'Não foi possível abrir o link');
  }
}
