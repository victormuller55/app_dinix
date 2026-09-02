import AppIntents
import Foundation

@available(iOS 16.0, *)
struct DinixShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ConsultarGastosIntent(),
            phrases: [
                "Quanto eu gastei no \(.applicationName)",
                "Consultar gastos no \(.applicationName)",
                "Meus gastos no \(.applicationName)",
                "Qual foi meu gasto no \(.applicationName)",
            ],
            shortTitle: "Consultar gastos",
            systemImageName: "creditcard"
        )
        AppShortcut(
            intent: ConsultarReceitasIntent(),
            phrases: [
                "Quanto eu recebi no \(.applicationName)",
                "Consultar receitas no \(.applicationName)",
                "Minhas receitas no \(.applicationName)",
            ],
            shortTitle: "Consultar receitas",
            systemImageName: "arrow.down.circle"
        )
        AppShortcut(
            intent: ConsultarSaldoIntent(),
            phrases: [
                "Qual meu saldo no \(.applicationName)",
                "Quanto dinheiro eu tenho no \(.applicationName)",
                "Como estão minhas finanças no \(.applicationName)",
            ],
            shortTitle: "Consultar saldo",
            systemImageName: "banknote"
        )
        AppShortcut(
            intent: ConsultarContasPagarIntent(),
            phrases: [
                "Quais contas eu tenho para pagar no \(.applicationName)",
                "Consultar contas no \(.applicationName)",
                "Contas atrasadas no \(.applicationName)",
            ],
            shortTitle: "Consultar contas",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: ConsultarAssinaturasIntent(),
            phrases: [
                "Minhas assinaturas no \(.applicationName)",
                "Quanto gasto com assinaturas no \(.applicationName)",
            ],
            shortTitle: "Consultar assinaturas",
            systemImageName: "repeat"
        )
        AppShortcut(
            intent: ConsultarInvestimentosIntent(),
            phrases: [
                "Quanto tenho investido no \(.applicationName)",
                "Consultar investimentos no \(.applicationName)",
            ],
            shortTitle: "Consultar investimentos",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
        AppShortcut(
            intent: RegistrarDespesaIntent(),
            phrases: [
                "Registrar despesa no \(.applicationName)",
                "Adicionar uma despesa no \(.applicationName)",
                "Registrar compra no \(.applicationName)",
            ],
            shortTitle: "Registrar despesa",
            systemImageName: "minus.circle"
        )
        AppShortcut(
            intent: RegistrarReceitaIntent(),
            phrases: [
                "Registrar receita no \(.applicationName)",
                "Adicionar uma receita no \(.applicationName)",
            ],
            shortTitle: "Registrar receita",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: PesquisarNoDinixIntent(),
            phrases: [
                "Pesquisar no \(.applicationName)",
                "Buscar no \(.applicationName)",
            ],
            shortTitle: "Pesquisar",
            systemImageName: "magnifyingglass"
        )
    }
}
