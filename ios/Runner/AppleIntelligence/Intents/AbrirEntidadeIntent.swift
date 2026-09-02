import AppIntents
import Foundation

@available(iOS 16.0, *)
struct AbrirCompraIntent: OpenIntent {
    static var title: LocalizedStringResource = "Abrir compra"
    static var openAppWhenRun = true

    @Parameter(title: "Compra")
    var target: CompraEntity

    func perform() async throws -> some IntentResult {
        DinixSessionStore.shared.setPendingRoute(route: "compra", entityId: target.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct AbrirReceitaIntent: OpenIntent {
    static var title: LocalizedStringResource = "Abrir receita"
    static var openAppWhenRun = true

    @Parameter(title: "Receita")
    var target: ReceitaEntity

    func perform() async throws -> some IntentResult {
        DinixSessionStore.shared.setPendingRoute(route: "receita", entityId: target.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct AbrirAssinaturaIntent: OpenIntent {
    static var title: LocalizedStringResource = "Abrir assinatura"
    static var openAppWhenRun = true

    @Parameter(title: "Assinatura")
    var target: AssinaturaEntity

    func perform() async throws -> some IntentResult {
        DinixSessionStore.shared.setPendingRoute(route: "assinatura", entityId: target.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct AbrirGastoMensalIntent: OpenIntent {
    static var title: LocalizedStringResource = "Abrir conta a pagar"
    static var openAppWhenRun = true

    @Parameter(title: "Conta a pagar")
    var target: GastoMensalEntity

    func perform() async throws -> some IntentResult {
        DinixSessionStore.shared.setPendingRoute(route: "gasto_mensal", entityId: target.id)
        return .result()
    }
}

@available(iOS 16.0, *)
struct PesquisarNoDinixIntent: AppIntent {
    static var title: LocalizedStringResource = "Pesquisar no Dinix"
    static var description = IntentDescription("Pesquisa lançamentos do Dinix por texto.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Busca", requestValueDialog: IntentDialog("O que você quer pesquisar no Dinix?"))
    var busca: String

    static var parameterSummary: some ParameterSummary {
        Summary("Pesquisar \(\PesquisarNoDinixIntent.$busca) no Dinix") {}
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let transacoes = try await client.transacoes(busca: busca)
        let text: String
        if transacoes.isEmpty {
            text = "Não encontrei lançamentos para \"\(busca)\"."
        } else {
            text = "Encontrei no Dinix:\n" + transacoes.prefix(8).map {
                "\($0.descricao): \($0.valor.formatted())"
            }.joined(separator: "\n")
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}
