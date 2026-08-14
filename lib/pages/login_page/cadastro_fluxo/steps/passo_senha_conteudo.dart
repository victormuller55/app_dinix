import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/widgets/login/login_form_field.dart';
import 'package:flutter/material.dart';
import 'package:app_dinix/app_config/const/phosphor_icons.dart';

class PassoSenhaConteudo extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PassoSenhaConteudo({super.key, required this.formKey});

  @override
  State<PassoSenhaConteudo> createState() => PassoSenhaConteudoState();
}

class PassoSenhaConteudoState extends State<PassoSenhaConteudo> {
  late final LoginFormField _campo;

  @override
  void initState() {
    super.initState();
    _campo = LoginFormField(
      hint: 'Digite sua senha',
      icon: Phosphor.lock,
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: validateSenhaCadastro,
    );
  }

  String get valor => _campo.value;

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
