import Foundation

protocol DinixHTTPPerforming: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: DinixHTTPPerforming {}

struct DinixAPIClient: Sendable {
    let sessionStore: DinixSessionStore
    let http: any DinixHTTPPerforming

    init(
        sessionStore: DinixSessionStore = .shared,
        http: any DinixHTTPPerforming = URLSession.shared
    ) {
        self.sessionStore = sessionStore
        self.http = http
    }

    func requireSession() throws {
        guard sessionStore.isAuthenticated else {
            throw sessionStore.accessToken == nil ? DinixAPIError.notAuthenticated : DinixAPIError.sessionExpired
        }
    }

    func getJSON(path: String, query: [String: String] = [:]) async throws -> DinixJSON {
        try requireSession()
        let data = try await request(method: "GET", path: path, query: query, body: nil)
        return try parseObject(data)
    }

    func getList(path: String, query: [String: String] = [:]) async throws -> [DinixJSON] {
        let json = try await getJSON(path: path, query: query)
        if let itens = json.raw["itens"] as? [Any] {
            return itens.compactMap { $0 as? [String: Any] }.map(DinixJSON.init)
        }
        if let list = json.raw["data"] as? [Any] {
            return list.compactMap { $0 as? [String: Any] }.map(DinixJSON.init)
        }
        return []
    }

    func postJSON(path: String, body: [String: Any], query: [String: String] = [:]) async throws -> DinixJSON {
        try requireSession()
        let data = try await request(method: "POST", path: path, query: query, body: body)
        if data.isEmpty { return DinixJSON([:]) }
        return (try? parseObject(data)) ?? DinixJSON([:])
    }

    func putJSON(path: String, body: [String: Any]) async throws -> DinixJSON {
        try requireSession()
        let data = try await request(method: "PUT", path: path, query: [:], body: body)
        if data.isEmpty { return DinixJSON([:]) }
        return (try? parseObject(data)) ?? DinixJSON([:])
    }

    func delete(path: String) async throws {
        try requireSession()
        _ = try await request(method: "DELETE", path: path, query: [:], body: nil)
    }

    func fetchAllPages(
        path: String,
        query: [String: String] = [:],
        itensPag: Int = 50,
        maxPages: Int = 8
    ) async throws -> [DinixJSON] {
        var collected: [DinixJSON] = []
        var page = 1
        while page <= maxPages {
            var params = query
            params["num_pag"] = String(page)
            params["itens_pag"] = String(itensPag)
            let json = try await getJSON(path: path, query: params)
            let itens = (json.raw["itens"] as? [Any] ?? []).compactMap { $0 as? [String: Any] }.map(DinixJSON.init)
            collected.append(contentsOf: itens)
            let maxPag = json.int("max_pag") ?? json.int("max_paginas") ?? (itens.isEmpty ? page : page)
            if itens.isEmpty || page >= maxPag { break }
            page += 1
        }
        return collected
    }

    private func request(
        method: String,
        path: String,
        query: [String: String],
        body: [String: Any]?
    ) async throws -> Data {
        var components = URLComponents(string: "\(sessionStore.apiBaseURL)/api/v1\(path)")
        if !query.isEmpty {
            components?.queryItems = query
                .filter { !$0.value.isEmpty }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw DinixAPIError.unavailable }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(sessionStore.clientId, forHTTPHeaderField: "X-Client-Id")
        request.setValue(sessionStore.clientSecret, forHTTPHeaderField: "X-Client-Secret")
        request.setValue(sessionStore.appVersion, forHTTPHeaderField: "X-App-Version")
        request.setValue("ios", forHTTPHeaderField: "X-Platform")
        request.setValue(sessionStore.deviceId, forHTTPHeaderField: "X-Device-Id")
        if let token = sessionStore.accessToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "autorizacao")
        }
        if let body {
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await http.data(for: request)
        } catch {
            throw DinixAPIError.unavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DinixAPIError.unavailable
        }
        if (200..<300).contains(httpResponse.statusCode) {
            return data
        }
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        throw DinixAPIError.from(statusCode: httpResponse.statusCode, body: json)
    }

    private func parseObject(_ data: Data) throws -> DinixJSON {
        guard !data.isEmpty else { return DinixJSON([:]) }
        let object = try JSONSerialization.jsonObject(with: data)
        if let dict = object as? [String: Any] {
            return DinixJSON(dict)
        }
        throw DinixAPIError.unavailable
    }
}

extension DinixAPIClient {
    func painel(mes: Int? = nil, ano: Int? = nil) async throws -> DinixPainelRecord {
        var query: [String: String] = [:]
        if let mes { query["mes"] = String(mes) }
        if let ano { query["ano"] = String(ano) }
        return DinixPainelRecord(try await getJSON(path: "/painel", query: query))
    }

    func patrimonio() async throws -> DinixPatrimonioRecord {
        DinixPatrimonioRecord(try await getJSON(path: "/patrimonio"))
    }

    func patrimonioHistorico() async throws -> [DinixPatrimonioHistoricoItem] {
        try await getList(path: "/patrimonio/historico", query: ["num_pag": "1", "itens_pag": "24"])
            .map { DinixPatrimonioHistoricoItem($0) }
    }

    func transacoes(
        tipo: String? = nil,
        dataInicio: String? = nil,
        dataFim: String? = nil,
        idCategoria: String? = nil,
        busca: String? = nil
    ) async throws -> [DinixTransacaoRecord] {
        var query: [String: String] = [:]
        if let tipo { query["tipo"] = tipo }
        if let dataInicio { query["data_inicio"] = dataInicio }
        if let dataFim { query["data_fim"] = dataFim }
        if let idCategoria { query["id_categoria"] = idCategoria }
        if let busca { query["busca"] = busca }
        return try await fetchAllPages(path: "/transacoes/busca", query: query)
            .map { DinixTransacaoRecord($0) }
    }

    func compras(mes: Int? = nil, ano: Int? = nil, dias: [String] = []) async throws -> [DinixCompraRecord] {
        var query: [String: String] = [:]
        if let mes { query["mes"] = String(mes) }
        if let ano { query["ano"] = String(ano) }
        if !dias.isEmpty { query["dias"] = dias.joined(separator: ",") }
        return try await fetchAllPages(path: "/compras", query: query).map { DinixCompraRecord($0) }
    }

    func receitas() async throws -> [DinixReceitaRecord] {
        try await fetchAllPages(path: "/receitas").map { DinixReceitaRecord($0) }
    }

    func gastosMensais() async throws -> [DinixGastoMensalRecord] {
        try await fetchAllPages(path: "/despesas-recorrentes").map { DinixGastoMensalRecord($0) }
    }

    func gastosMensaisPendentes(data: String) async throws -> [DinixGastoMensalRecord] {
        try await getList(path: "/despesas-recorrentes/pendentes", query: ["data": data])
            .map { DinixGastoMensalRecord($0) }
    }

    func assinaturas() async throws -> [DinixAssinaturaRecord] {
        try await fetchAllPages(path: "/assinaturas").map { DinixAssinaturaRecord($0) }
    }

    func assinaturasPendentes(data: String) async throws -> [DinixAssinaturaRecord] {
        try await getList(path: "/assinaturas/pendentes", query: ["data": data])
            .map { DinixAssinaturaRecord($0) }
    }

    func assinaturasResumo() async throws -> DinixAssinaturaResumoRecord {
        DinixAssinaturaResumoRecord(try await getJSON(path: "/assinaturas/resumo"))
    }

    func categorias() async throws -> [DinixCategoriaRecord] {
        try await fetchAllPages(path: "/categorias", itensPag: 100).map { DinixCategoriaRecord($0) }
    }

    func locais() async throws -> [DinixLocalRecord] {
        try await fetchAllPages(path: "/locais").map { DinixLocalRecord($0) }
    }

    func contas() async throws -> [DinixContaRecord] {
        try await fetchAllPages(path: "/contas").map { DinixContaRecord($0) }
    }

    func criarCompra(
        descricao: String,
        valor: DinixMoney,
        data: String,
        idCategoria: String?,
        idLocal: String?,
        formaPagamento: String,
        idConta: String?,
        idCartao: String?,
        parcelas: Int
    ) async throws -> DinixJSON {
        var body: [String: Any] = [
            "descricao": descricao,
            "data_compra": data,
            "hora_compra": DinixDateRange.currentTimeHHmmss(),
            "valor_total": valor.apiString(),
            "forma_pagamento": formaPagamento,
            "qtd_parcelas": parcelas,
            "ids_etiquetas": [String](),
            "itens": [[String: Any]](),
        ]
        if let idCategoria { body["id_categoria"] = idCategoria }
        if let idLocal { body["id_local"] = idLocal }
        if let idConta { body["id_conta"] = idConta }
        if let idCartao { body["id_cartao_credito"] = idCartao }
        if parcelas > 1 { body["data_primeira_parcela"] = data }
        return try await postJSON(path: "/compras", body: body)
    }

    func criarReceita(
        descricao: String,
        valor: DinixMoney,
        data: String,
        idCategoria: String?,
        idConta: String?
    ) async throws -> DinixJSON {
        var body: [String: Any] = [
            "descricao": descricao,
            "valor": valor.apiString(),
            "data_recebimento": data,
            "recorrente": false,
        ]
        if let idCategoria { body["id_categoria"] = idCategoria }
        if let idConta { body["id_conta"] = idConta }
        return try await postJSON(path: "/receitas", body: body)
    }

    func criarGastoMensal(
        nome: String,
        valor: DinixMoney,
        diaVencimento: Int,
        idConta: String?,
        idCategoria: String?
    ) async throws -> DinixJSON {
        var body: [String: Any] = [
            "nome": nome,
            "valor": valor.apiString(),
            "forma_pagamento": "pix",
            "dia_vencimento": diaVencimento,
            "data_inicio": DinixDateRange.isoDate(Date()),
            "recorrencia": "mensal",
        ]
        if let idConta { body["id_conta"] = idConta }
        if let idCategoria { body["id_categoria"] = idCategoria }
        return try await postJSON(path: "/despesas-recorrentes", body: body)
    }

    func criarAssinatura(
        nome: String,
        valor: DinixMoney,
        diaCobranca: Int,
        idConta: String?,
        idCategoria: String?
    ) async throws -> DinixJSON {
        var body: [String: Any] = [
            "nome": nome,
            "valor": valor.apiString(),
            "forma_pagamento": "pix",
            "dia_cobranca": diaCobranca,
            "data_inicio": DinixDateRange.isoDate(Date()),
            "recorrencia": "mensal",
        ]
        if let idConta { body["id_conta"] = idConta }
        if let idCategoria { body["id_categoria"] = idCategoria }
        return try await postJSON(path: "/assinaturas", body: body)
    }
}
