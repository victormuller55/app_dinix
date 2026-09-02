import Foundation

struct DinixJSON {
    let raw: [String: Any]

    init(_ raw: [String: Any]) {
        self.raw = raw
    }

    func string(_ key: String) -> String? {
        guard let value = raw[key] else { return nil }
        let text = String(describing: value)
        return text.isEmpty || text == "<null>" ? nil : text
    }

    func int(_ key: String) -> Int? {
        if let value = raw[key] as? Int { return value }
        if let value = raw[key] as? NSNumber { return value.intValue }
        return Int(string(key) ?? "")
    }

    func bool(_ key: String) -> Bool {
        if let value = raw[key] as? Bool { return value }
        return string(key) == "true"
    }

    func money(_ key: String) -> DinixMoney {
        DinixMoney(jsonValue: raw[key])
    }

    func array(_ key: String) -> [[String: Any]] {
        (raw[key] as? [Any] ?? []).compactMap { $0 as? [String: Any] }
    }

    func object(_ key: String) -> DinixJSON? {
        guard let value = raw[key] as? [String: Any] else { return nil }
        return DinixJSON(value)
    }
}

struct DinixPaged<T> {
    let itens: [T]
    let numPag: Int
    let maxPag: Int
    let maxItens: Int

    var hasNext: Bool { maxPag > 0 && numPag < maxPag }
}

struct DinixCompraRecord {
    let id: String
    let descricao: String
    let dataCompra: String?
    let valorTotal: DinixMoney
    let idCategoria: String?
    let idLocal: String?
    let formaPagamento: String?
    let qtdParcelas: Int
    let valorParcela: DinixMoney
    let dataPrimeiraParcela: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        descricao = json.string("descricao") ?? "Compra"
        dataCompra = json.string("data_compra")
        valorTotal = json.money("valor_total")
        idCategoria = json.string("id_categoria")
        idLocal = json.string("id_local")
        formaPagamento = json.string("forma_pagamento")
        qtdParcelas = json.int("qtd_parcelas") ?? 1
        valorParcela = json.money("valor_parcela")
        dataPrimeiraParcela = json.string("data_primeira_parcela")
    }

    var isParcelada: Bool { qtdParcelas > 1 }
}

struct DinixReceitaRecord {
    let id: String
    let descricao: String
    let valor: DinixMoney
    let dataRecebimento: String?
    let idCategoria: String?
    let idConta: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        descricao = json.string("descricao") ?? "Receita"
        valor = json.money("valor")
        dataRecebimento = json.string("data_recebimento")
        idCategoria = json.string("id_categoria")
        idConta = json.string("id_conta")
    }
}

struct DinixGastoMensalRecord {
    let id: String
    let nome: String
    let valor: DinixMoney
    let diaVencimento: Int?
    let ativo: Bool
    let idCategoria: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        nome = json.string("nome") ?? "Gasto mensal"
        valor = json.money("valor")
        diaVencimento = json.int("dia_vencimento")
        ativo = json.raw["ativo"] == nil ? true : json.bool("ativo")
        idCategoria = json.string("id_categoria")
    }
}

struct DinixAssinaturaRecord {
    let id: String
    let nome: String
    let valor: DinixMoney
    let diaCobranca: Int?
    let dataProximaCobranca: String?
    let recorrencia: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        nome = json.string("nome") ?? "Assinatura"
        valor = json.money("valor")
        diaCobranca = json.int("dia_cobranca")
        dataProximaCobranca = json.string("data_proxima_cobranca")
        recorrencia = json.string("recorrencia")
    }
}

struct DinixCategoriaRecord {
    let id: String
    let nome: String
    let tipo: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        nome = json.string("nome") ?? "Categoria"
        tipo = json.string("tipo")
    }
}

struct DinixLocalRecord {
    let id: String
    let nome: String
    let nomeCategoria: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        nome = json.string("nome") ?? "Local"
        nomeCategoria = json.string("nome_categoria")
    }
}

struct DinixContaRecord {
    let id: String
    let nome: String
    let nomeBanco: String?
    let saldoAtual: DinixMoney
    let tipoConta: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        nome = json.string("nome") ?? json.string("nome_banco") ?? "Conta"
        nomeBanco = json.string("nome_banco")
        saldoAtual = json.money("saldo_atual")
        tipoConta = json.string("tipo_conta")
    }
}

struct DinixTransacaoRecord {
    let id: String
    let tipo: String
    let valor: DinixMoney
    let data: String?
    let descricao: String
    let idCategoria: String?
    let idCompra: String?
    let idReceita: String?

    init(_ json: DinixJSON) {
        id = json.string("id") ?? ""
        tipo = json.string("tipo") ?? ""
        valor = json.money("valor")
        data = json.string("data_transacao")
        descricao = json.string("descricao") ?? "Lançamento"
        idCategoria = json.string("id_categoria")
        idCompra = json.string("id_compra")
        idReceita = json.string("id_receita")
    }
}

struct DinixPainelRecord {
    let mes: Int
    let ano: Int
    let receitas: DinixMoney
    let despesas: DinixMoney
    let investimentos: DinixMoney
    let disponivel: DinixMoney
    let despesasPorCategoria: [(nome: String, valor: DinixMoney)]
    let proximosPagamentos: [DinixProximoPagamento]

    init(_ json: DinixJSON) {
        mes = json.int("mes") ?? Calendar.current.component(.month, from: Date())
        ano = json.int("ano") ?? Calendar.current.component(.year, from: Date())
        receitas = json.object("receitas")?.money("total") ?? .zero
        despesas = json.object("despesas")?.money("total") ?? .zero
        investimentos = json.money("investimentos")
        disponivel = json.money("disponivel")
        despesasPorCategoria = json.array("despesas_por_categoria").map { item in
            let obj = DinixJSON(item)
            return (obj.string("categoria") ?? "Categoria", obj.money("valor"))
        }
        proximosPagamentos = json.array("proximos_pagamentos").map { DinixProximoPagamento(DinixJSON($0)) }
    }
}

struct DinixProximoPagamento {
    let tipo: String
    let descricao: String
    let valor: DinixMoney
    let dataVencimento: String?

    init(_ json: DinixJSON) {
        tipo = json.string("tipo") ?? ""
        descricao = json.string("descricao") ?? "Pagamento"
        valor = json.money("valor")
        dataVencimento = json.string("data_vencimento")
    }
}

struct DinixPatrimonioRecord {
    let saldoContas: DinixMoney
    let valorInvestimentos: DinixMoney
    let dividas: DinixMoney
    let patrimonio: DinixMoney

    init(_ json: DinixJSON) {
        saldoContas = json.money("saldo_contas")
        valorInvestimentos = json.money("valor_investimentos")
        dividas = json.money("dividas")
        patrimonio = json.money("patrimonio")
    }
}

struct DinixAssinaturaResumoRecord {
    let totalMensal: DinixMoney
    let totalAnual: DinixMoney
    let proximos: [(id: String?, nome: String, valor: DinixMoney, data: String?)]

    init(_ json: DinixJSON) {
        totalMensal = json.money("total_mensal")
        totalAnual = json.money("total_anual")
        proximos = json.array("proximos_pagamentos").map { item in
            let obj = DinixJSON(item)
            return (
                obj.string("id_assinatura"),
                obj.string("nome") ?? "Assinatura",
                obj.money("valor"),
                obj.string("data")
            )
        }
    }
}

struct DinixPatrimonioHistoricoItem {
    let mes: Int
    let ano: Int
    let saldoContas: DinixMoney
    let valorInvestimentos: DinixMoney

    init(_ json: DinixJSON) {
        mes = json.int("mes") ?? 0
        ano = json.int("ano") ?? 0
        saldoContas = json.money("saldo_contas")
        valorInvestimentos = json.money("valor_investimentos")
    }
}
