import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/widgets/login/login_form_field.dart';
import 'package:flutter/material.dart';
import 'package:app_dinix/app_config/const/phosphor_icons.dart';

class PassoEmailConteudo extends StatefulWidget {
  final String valorInicial;
  final GlobalKey<FormState> formKey;

  const PassoEmailConteudo({
    super.key,
    required this.valorInicial,
    required this.formKey,
  });

  @override
  State<PassoEmailConteudo> createState() => PassoEmailConteudoState();
}

class PassoEmailConteudoState extends State<PassoEmailConteudo> {
  late final LoginFormField _campo;

  @override
  void initState() {
    super.initState();
    _campo = LoginFormField(
      hint: 'Digite seu e-mail',
      icon: Phosphor.envelope,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: validateEmail,
    );
    _campo.controller.text = widget.valorInicial;
  }

  String get valor => _campo.value.trim();

  bool validar() => widget.formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _campo.formulario,
    );
  }

  @override
  void dispose() {
    _campo.controller.dispose();
    _campo.focusNode.dispose();
    super.dispose();
  }
}
