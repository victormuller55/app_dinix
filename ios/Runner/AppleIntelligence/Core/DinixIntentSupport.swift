import AppIntents
import Foundation

@available(iOS 16.0, *)
enum DinixIntentSupport {
    static func client() -> DinixAPIClient {
        DinixAPIClient()
    }

    static func range(
        periodo: PeriodoConsulta?,
        dataInicial: Date?,
        dataFinal: Date?
    ) -> DinixDateRange {
        if let dataInicial, let dataFinal {
            return DinixDateRange.resolve(
                periodo: .personalizado,
                dataInicial: dataInicial,
                dataFinal: dataFinal
            )
        }
        if let dataInicial {
            return DinixDateRange.resolve(
                periodo: .personalizado,
                dataInicial: dataInicial,
                dataFinal: dataInicial
            )
        }
        if let dataFinal {
            return DinixDateRange.resolve(
                periodo: .personalizado,
                dataInicial: dataFinal,
                dataFinal: dataFinal
            )
        }
        if let periodo {
            return DinixDateRange.resolve(periodo: periodo.dominio)
        }
        return DinixDateRange.resolve(periodo: .esteMes)
    }

    static func dialog(_ text: String) -> IntentDialog {
        IntentDialog(stringLiteral: text)
    }

    static func formatList(_ lines: [String], empty: String) -> String {
        let trimmed = lines.filter { !$0.isEmpty }
        if trimmed.isEmpty { return empty }
        return trimmed.joined(separator: "\n")
    }

    static func firstAccountId(_ client: DinixAPIClient) async throws -> String? {
        try await client.contas().first?.id
    }

    static func resolveAccountId(_ explicit: String?, client: DinixAPIClient) async throws -> String? {
        if let explicit { return explicit }
        return try await firstAccountId(client)
    }

    static func resolveCategoria(named nome: String?, from client: DinixAPIClient) async throws -> DinixCategoriaRecord? {
        guard let nome, !nome.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        let needle = nome.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
        return try await client.categorias().first {
            $0.nome.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
                .contains(needle)
        }
    }

    static func resolveLocal(named nome: String?, from client: DinixAPIClient) async throws -> DinixLocalRecord? {
        guard let nome, !nome.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        let needle = nome.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
        return try await client.locais().first {
            $0.nome.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
                .contains(needle)
        }
    }
}
