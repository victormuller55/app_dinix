enum CadastroFluxoPasso {
  nome,
  email,
  confirmarEmail,
  codigo,
  senha,
  contas,
  saldo,
  cartoes,
}

extension CadastroFluxoPassoExt on CadastroFluxoPasso {
  int get indice => CadastroFluxoPasso.values.indexOf(this);

  double get progresso => (indice + 1) / CadastroFluxoPasso.values.length;

  String get titulo {
    switch (this) {
      case CadastroFluxoPasso.nome:
        return 'Como podemos te chamar?';
      case CadastroFluxoPasso.email:
        return 'Qual é o seu e-mail?';
      case CadastroFluxoPasso.confirmarEmail:
        return 'Confirme seu e-mail';
      case CadastroFluxoPasso.codigo:
        return 'Digite o código';
      case CadastroFluxoPasso.senha:
        return 'Crie sua senha';
      case CadastroFluxoPasso.contas:
        return 'Suas contas bancárias';
      case CadastroFluxoPasso.saldo:
        return 'Saldo das contas';
      case CadastroFluxoPasso.cartoes:
        return 'Cartões de crédito';
    }
  }

  String get subtitulo {
    switch (this) {
      case CadastroFluxoPasso.nome:
        return 'Usamos seu nome para personalizar o app.';
      case CadastroFluxoPasso.email:
        return 'Enviaremos um código de verificação para este endereço.';
      case CadastroFluxoPasso.confirmarEmail:
        return 'Confirme o endereço antes de receber o código.';
      case CadastroFluxoPasso.codigo:
        return 'Informe o código que enviamos para o seu e-mail.';
      case CadastroFluxoPasso.senha:
        return 'Mínimo de 8 caracteres para manter sua conta segura.';
      case CadastroFluxoPasso.contas:
        return 'Selecione os bancos que você usa no dia a dia.';
      case CadastroFluxoPasso.saldo:
        return 'Informe quanto você tem em cada conta hoje.';
      case CadastroFluxoPasso.cartoes:
        return 'Opcional — informe limite, fechamento e vencimento de cada cartão.';
    }
  }

  CadastroFluxoPasso? get anterior {
    if (indice <= 0) return null;
    return CadastroFluxoPasso.values[indice - 1];
  }

  CadastroFluxoPasso? get proximo {
    if (indice >= CadastroFluxoPasso.values.length - 1) return null;
    return CadastroFluxoPasso.values[indice + 1];
  }
}
