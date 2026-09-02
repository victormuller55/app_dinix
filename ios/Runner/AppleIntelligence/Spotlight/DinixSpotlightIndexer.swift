import AppIntents
import CoreSpotlight
import Foundation

enum DinixSpotlightIndexer {
    static let indexName = "dinix-entities"

    static func reindexSafeEntities() async {
        guard #available(iOS 18.0, *) else { return }
        guard DinixSessionStore.shared.isAuthenticated else { return }

        do {
            let client = DinixAPIClient()
            let categorias = try await client.categorias().map {
                CategoriaEntity(id: $0.id, nome: $0.nome, tipo: $0.tipo)
            }
            let locais = try await client.locais().map {
                LocalEntity(id: $0.id, nome: $0.nome)
            }
            let assinaturas = try await client.assinaturas().map {
                AssinaturaEntity(id: $0.id, nome: $0.nome, valor: "", proximaCobranca: nil)
            }
            let gastos = try await client.gastosMensais().map {
                GastoMensalEntity(id: $0.id, nome: $0.nome, valor: "", diaVencimento: $0.diaVencimento)
            }

            let index = CSSearchableIndex(name: indexName)
            try await index.indexAppEntities(categorias)
            try await index.indexAppEntities(locais)
            try await index.indexAppEntities(assinaturas)
            try await index.indexAppEntities(gastos)
        } catch {
            // Indexação é complementar; falha não deve afetar o app.
        }
    }

    static func clear() {
        CSSearchableIndex(name: indexName).deleteAllSearchableItems { _ in }
    }
}
