import AppIntents
import Foundation

@available(iOS 16.0, *)
struct RegistrarDespesaIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar despesa"
    static var description = IntentDescription(
        "Registra uma despesa pontual no Dinix como compra, com valor, categoria ou estabelecimento."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Valor", requestValueDialog: IntentDialog("Qual o valor da despesa?"))
    var valor: Double

    @Parameter(title: "Descrição")
    var descricao: String?

    @Parameter(title: "Categoria")
    var categoria: CategoriaEntity?

    @Parameter(title: "Estabelecimento")
    var estabelecimento: LocalEntity?

    @Parameter(title: "Conta")
    var conta: ContaBancariaEntity?

    @Parameter(title: "Forma de pagamento")
    var formaPagamento: FormaPagamentoSiri?

    @Parameter(title: "Data")
    var data: Date?

    @Parameter(title: "Parcelas")
    var parcelas: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Registrar despesa de \(\.$valor)") {
            \.$descricao
            \.$categoria
            \.$estabelecimento
            \.$parcelas
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let money = DinixMoney(intentValue: valor)
        if money.isZero { throw DinixAPIError.validation("Informe o valor da despesa.") }
        let titulo = descricao
            ?? estabelecimento?.nome
            ?? categoria?.nome
            ?? "Despesa"
        let qtd = max(parcelas ?? 1, 1)
        try await confirmar(
            "Registrar despesa de \(money.formatted()) em \(titulo)\(qtd > 1 ? " em \(qtd) vezes" : "")?"
        )
        let client = DinixIntentSupport.client()
        let contaId = try await DinixIntentSupport.resolveAccountId(conta?.id, client: client)
        let dataISO = DinixDateRange.isoDate(data ?? Date())
        _ = try await client.criarCompra(
            descricao: titulo,
            valor: money,
            data: dataISO,
            idCategoria: categoria?.id,
            idLocal: estabelecimento?.id,
            formaPagamento: formaPagamento?.apiValue ?? "pix",
            idConta: contaId,
            idCartao: nil,
            parcelas: qtd
        )
        let text = qtd > 1
            ? "Registrei a compra de \(money.formatted()) em \(titulo), parcelada em \(qtd) vezes."
            : "Registrei a despesa de \(money.formatted()) em \(titulo)."
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct RegistrarReceitaIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar receita"
    static var description = IntentDescription("Registra uma receita pontual no Dinix.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Valor", requestValueDialog: IntentDialog("Qual o valor da receita?"))
    var valor: Double

    @Parameter(title: "Descrição")
    var descricao: String?

    @Parameter(title: "Categoria")
    var categoria: CategoriaEntity?

    @Parameter(title: "Conta")
    var conta: ContaBancariaEntity?

    @Parameter(title: "Data")
    var data: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Registrar receita de \(\.$valor)") {
            \.$descricao
            \.$categoria
            \.$conta
            \.$data
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let money = DinixMoney(intentValue: valor)
        if money.isZero { throw DinixAPIError.validation("Informe o valor da receita.") }
        let titulo = descricao ?? categoria?.nome ?? "Receita"
        try await confirmar("Registrar receita de \(money.formatted()) em \(titulo)?")
        let client = DinixIntentSupport.client()
        _ = try await client.criarReceita(
            descricao: titulo,
            valor: money,
            data: DinixDateRange.isoDate(data ?? Date()),
            idCategoria: categoria?.id,
            idConta: try await DinixIntentSupport.resolveAccountId(conta?.id, client: client)
        )
        let text = "Registrei a receita de \(money.formatted()) em \(titulo)."
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct RegistrarContaPagarIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar conta a pagar"
    static var description = IntentDescription(
        "Cadastra uma despesa recorrente no Dinix. Conta a pagar não é conta bancária."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Valor", requestValueDialog: IntentDialog("Qual o valor da conta?"))
    var valor: Double

    @Parameter(title: "Nome", requestValueDialog: IntentDialog("Qual o nome da conta?"))
    var nome: String

    @Parameter(title: "Dia do vencimento")
    var diaVencimento: Int?

    @Parameter(title: "Conta bancária")
    var conta: ContaBancariaEntity?

    @Parameter(title: "Categoria")
    var categoria: CategoriaEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Registrar conta \(\.$nome) de \(\.$valor)") {
            \.$diaVencimento
            \.$conta
            \.$categoria
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let money = DinixMoney(intentValue: valor)
        let dia = min(max(diaVencimento ?? Calendar.current.component(.day, from: Date()), 1), 31)
        try await confirmar("Cadastrar a conta \(nome) de \(money.formatted()) com vencimento no dia \(dia)?")
        let client = DinixIntentSupport.client()
        _ = try await client.criarGastoMensal(
            nome: nome,
            valor: money,
            diaVencimento: dia,
            idConta: try await DinixIntentSupport.resolveAccountId(conta?.id, client: client),
            idCategoria: categoria?.id
        )
        let text = "Cadastrei a conta \(nome) de \(money.formatted())."
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct RegistrarAssinaturaIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar assinatura"
    static var description = IntentDescription("Cadastra uma assinatura recorrente no Dinix.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Valor", requestValueDialog: IntentDialog("Qual o valor da assinatura?"))
    var valor: Double

    @Parameter(title: "Nome", requestValueDialog: IntentDialog("Qual o nome da assinatura?"))
    var nome: String

    @Parameter(title: "Dia da cobrança")
    var diaCobranca: Int?

    @Parameter(title: "Conta bancária")
    var conta: ContaBancariaEntity?

    @Parameter(title: "Categoria")
    var categoria: CategoriaEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Registrar assinatura \(\.$nome) de \(\.$valor)") {
            \.$diaCobranca
            \.$conta
            \.$categoria
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let money = DinixMoney(intentValue: valor)
        let dia = min(max(diaCobranca ?? Calendar.current.component(.day, from: Date()), 1), 31)
        try await confirmar("Cadastrar a assinatura \(nome) de \(money.formatted())?")
        let client = DinixIntentSupport.client()
        _ = try await client.criarAssinatura(
            nome: nome,
            valor: money,
            diaCobranca: dia,
            idConta: try await DinixIntentSupport.resolveAccountId(conta?.id, client: client),
            idCategoria: categoria?.id
        )
        let text = "Cadastrei a assinatura \(nome) de \(money.formatted())."
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct RegistrarInvestimentoIntent: AppIntent {
    static var title: LocalizedStringResource = "Registrar investimento"
    static var description = IntentDescription(
        "Informa que o cadastro de investimentos ainda não existe no aplicativo Dinix."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Valor")
    var valor: Double?

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let text = "O Dinix ainda não cadastra investimentos pelo aplicativo. Consulte o total investido pelo patrimônio."
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ExcluirRegistroIntent: AppIntent {
    static var title: LocalizedStringResource = "Excluir registro"
    static var description = IntentDescription("Exclui um registro do Dinix após confirmação.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoRegistroExclusao?

    @Parameter(title: "Compra")
    var compra: CompraEntity?

    @Parameter(title: "Receita")
    var receita: ReceitaEntity?

    @Parameter(title: "Conta a pagar")
    var gastoMensal: GastoMensalEntity?

    @Parameter(title: "Assinatura")
    var assinatura: AssinaturaEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Excluir \(\.$tipo)") {
            \.$compra
            \.$receita
            \.$gastoMensal
            \.$assinatura
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        if let compra {
            try await confirmarExclusao("Excluir a despesa \(compra.titulo) de \(compra.valor)?")
            try await client.delete(path: "/compras/\(compra.id)")
            let text = "Excluí a despesa \(compra.titulo)."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        if let receita {
            try await confirmarExclusao("Excluir a receita \(receita.titulo) de \(receita.valor)?")
            try await client.delete(path: "/receitas/\(receita.id)")
            let text = "Excluí a receita \(receita.titulo)."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        if let gastoMensal {
            try await confirmarExclusao("Excluir a conta \(gastoMensal.nome)?")
            try await client.delete(path: "/despesas-recorrentes/\(gastoMensal.id)")
            let text = "Excluí a conta \(gastoMensal.nome)."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        if let assinatura {
            try await confirmarExclusao("Excluir a assinatura \(assinatura.nome)?")
            try await client.delete(path: "/assinaturas/\(assinatura.id)")
            let text = "Excluí a assinatura \(assinatura.nome)."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        if let contexto = DinixSessionStore.shared.onScreenEntity() {
            let text = try await excluirContexto(contexto, client: client)
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        let text = "Diga qual registro deseja excluir, ou abra o item no Dinix."
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }

    private func excluirContexto(
        _ contexto: (type: String, id: String, title: String?),
        client: DinixAPIClient
    ) async throws -> String {
        let nome = contexto.title ?? "esse registro"
        try await confirmarExclusao("Excluir \(nome)?")
        switch contexto.type {
        case "compra":
            try await client.delete(path: "/compras/\(contexto.id)")
        case "receita":
            try await client.delete(path: "/receitas/\(contexto.id)")
        case "gasto_mensal":
            try await client.delete(path: "/despesas-recorrentes/\(contexto.id)")
        case "assinatura":
            try await client.delete(path: "/assinaturas/\(contexto.id)")
        default:
            return "Não consegui identificar o registro aberto no Dinix."
        }
        return "Excluí \(nome)."
    }
}

@available(iOS 16.0, *)
private extension AppIntent {
    func confirmar(_ mensagem: String) async throws {
        if #available(iOS 18.0, *) {
            try await requestConfirmation(actionName: .add, dialog: IntentDialog(stringLiteral: mensagem))
        }
    }

    func confirmarExclusao(_ mensagem: String) async throws {
        if #available(iOS 18.0, *) {
            try await requestConfirmation(actionName: .continue, dialog: IntentDialog(stringLiteral: mensagem))
        } else {
            throw DinixAPIError.unsupported("Confirme a exclusão abrindo o Dinix.")
        }
    }
}
