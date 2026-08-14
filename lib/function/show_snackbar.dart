import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/function/haptic.dart';
import 'package:app_dinix/function/service/api_error.dart';

void showToastSuccess({required String message}) {
  showSnackbarSuccess(message: message);
}

void showToastError({String? message}) {
  vibrateErrorFeedback();
  showSnackbarError(message: message);
}

void showToastWarning({required String message}) {
  showSnackbarWarning(message: message);
}

void showAppErrorSnackbar(ErrorModel errorModel) {
  final message = errorModel.mensagem?.trim();
  if (message == null || message.isEmpty) return;
  vibrateErrorFeedback();
  showSnackbarError(message: message);
}

void showAppErrorFromException(Object error) {
  showAppErrorSnackbar(errorModelFromException(error));
}
