import AppIntents
import Foundation

@available(iOS 16.0, *)
struct CompraEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Compra")
    static var defaultQuery = CompraEntityQuery()

    var id: String
    var titulo: String
    var valor: String
    var data: String?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(titulo)", subtitle: "\(valor)")
    }
}

@available(iOS 16.0, *)
struct CompraEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [CompraEntity] {
        let all = try await suggestedEntities()
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CompraEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().compras().prefix(20).map {
            CompraEntity(
                id: $0.id,
                titulo: $0.descricao,
                valor: $0.valorTotal.formatted(),
                data: $0.dataCompra
            )
        }
    }

    func entities(matching string: String) async throws -> [CompraEntity] {
        try await suggestedEntities().filter {
            $0.titulo.localizedCaseInsensitiveContains(string)
        }
    }
}

@available(iOS 16.0, *)
struct ReceitaEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Receita")
    static var defaultQuery = ReceitaEntityQuery()

    var id: String
    var titulo: String
    var valor: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(titulo)", subtitle: "\(valor)")
    }
}

@available(iOS 16.0, *)
struct ReceitaEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [ReceitaEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ReceitaEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().receitas().prefix(20).map {
            ReceitaEntity(id: $0.id, titulo: $0.descricao, valor: $0.valor.formatted())
        }
    }

    func entities(matching string: String) async throws -> [ReceitaEntity] {
        try await suggestedEntities().filter { $0.titulo.localizedCaseInsensitiveContains(string) }
    }
}

@available(iOS 16.0, *)
struct GastoMensalEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Conta a pagar")
    static var defaultQuery = GastoMensalEntityQuery()

    var id: String
    var nome: String
    var valor: String
    var diaVencimento: Int?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nome)", subtitle: "\(valor)")
    }
}

@available(iOS 16.0, *)
struct GastoMensalEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [GastoMensalEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [GastoMensalEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().gastosMensais().map {
            GastoMensalEntity(
                id: $0.id,
                nome: $0.nome,
                valor: $0.valor.formatted(),
                diaVencimento: $0.diaVencimento
            )
        }
    }

    func entities(matching string: String) async throws -> [GastoMensalEntity] {
        try await suggestedEntities().filter { $0.nome.localizedCaseInsensitiveContains(string) }
    }
}

@available(iOS 16.0, *)
struct AssinaturaEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Assinatura")
    static var defaultQuery = AssinaturaEntityQuery()

    var id: String
    var nome: String
    var valor: String
    var proximaCobranca: String?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nome)", subtitle: "\(valor)")
    }
}

@available(iOS 16.0, *)
struct AssinaturaEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [AssinaturaEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [AssinaturaEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().assinaturas().map {
            AssinaturaEntity(
                id: $0.id,
                nome: $0.nome,
                valor: $0.valor.formatted(),
                proximaCobranca: $0.dataProximaCobranca
            )
        }
    }

    func entities(matching string: String) async throws -> [AssinaturaEntity] {
        try await suggestedEntities().filter { $0.nome.localizedCaseInsensitiveContains(string) }
    }
}

@available(iOS 16.0, *)
struct CategoriaEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Categoria")
    static var defaultQuery = CategoriaEntityQuery()

    var id: String
    var nome: String
    var tipo: String?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nome)")
    }
}

@available(iOS 16.0, *)
struct CategoriaEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [CategoriaEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CategoriaEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().categorias().map {
            CategoriaEntity(id: $0.id, nome: $0.nome, tipo: $0.tipo)
        }
    }

    func entities(matching string: String) async throws -> [CategoriaEntity] {
        try await suggestedEntities().filter { $0.nome.localizedCaseInsensitiveContains(string) }
    }
}

@available(iOS 16.0, *)
struct LocalEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Estabelecimento")
    static var defaultQuery = LocalEntityQuery()

    var id: String
    var nome: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nome)")
    }
}

@available(iOS 16.0, *)
struct LocalEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [LocalEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [LocalEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().locais().map {
            LocalEntity(id: $0.id, nome: $0.nome)
        }
    }

    func entities(matching string: String) async throws -> [LocalEntity] {
        try await suggestedEntities().filter { $0.nome.localizedCaseInsensitiveContains(string) }
    }
}

@available(iOS 16.0, *)
struct ContaBancariaEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Conta bancária")
    static var defaultQuery = ContaBancariaEntityQuery()

    var id: String
    var nome: String
    var saldo: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nome)", subtitle: "\(saldo)")
    }
}

@available(iOS 16.0, *)
struct ContaBancariaEntityQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [ContaBancariaEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ContaBancariaEntity] {
        guard DinixSessionStore.shared.isAuthenticated else { return [] }
        return try await DinixAPIClient().contas().map {
            ContaBancariaEntity(id: $0.id, nome: $0.nome, saldo: $0.saldoAtual.formatted())
        }
    }

    func entities(matching string: String) async throws -> [ContaBancariaEntity] {
        try await suggestedEntities().filter { $0.nome.localizedCaseInsensitiveContains(string) }
    }
}

@available(iOS 18.0, *)
extension CategoriaEntity: IndexedEntity {}

@available(iOS 18.0, *)
extension LocalEntity: IndexedEntity {}

@available(iOS 18.0, *)
extension AssinaturaEntity: IndexedEntity {}

@available(iOS 18.0, *)
extension GastoMensalEntity: IndexedEntity {}
