import AppIntents
import Foundation

@available(iOS 16.0, *)
struct ConsultarGastosIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar gastos"
    static var description = IntentDescription(
        "Consulta gastos e despesas do Dinix por período, categoria ou estabelecimento."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Período", description: "Hoje, ontem, este mês, últimos 7 dias e outros períodos.")
    var periodo: PeriodoConsulta?

    @Parameter(title: "Data inicial")
    var dataInicial: Date?

    @Parameter(title: "Data final")
    var dataFinal: Date?

    @Parameter(title: "Categoria")
    var categoria: CategoriaEntity?

    @Parameter(title: "Estabelecimento")
    var estabelecimento: LocalEntity?

    @Parameter(title: "Tipo da consulta")
    var tipo: TipoConsultaGastos?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar gastos \(\.$periodo)") {
            \.$categoria
            \.$estabelecimento
            \.$tipo
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let range = DinixIntentSupport.range(
            periodo: periodo,
            dataInicial: dataInicial,
            dataFinal: dataFinal
        )
        let consulta = tipo ?? .total
        let text = try await Self.consultar(
            client: client,
            range: range,
            categoria: categoria,
            estabelecimento: estabelecimento,
            tipo: consulta
        )
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }

    static func consultar(
        client: DinixAPIClient,
        range: DinixDateRange,
        categoria: CategoriaEntity?,
        estabelecimento: LocalEntity?,
        tipo: TipoConsultaGastos
    ) async throws -> String {
        if estabelecimento == nil, categoria == nil, range.isCalendarMonth, tipo == .total {
            let painel = try await client.painel(mes: range.mes, ano: range.ano)
            if painel.despesas.isZero {
                return "Não encontrei gastos \(range.spokenDescription())."
            }
            return "Você gastou \(painel.despesas.formatted()) \(range.spokenDescription())."
        }

        if let estabelecimento {
            let compras = try await comprasNoPeriodo(client: client, range: range)
                .filter { $0.idLocal == estabelecimento.id }
            return formatarCompras(
                compras,
                tipo: tipo,
                periodo: range,
                contexto: "em \(estabelecimento.nome)"
            )
        }

        let transacoes = try await client.transacoes(
            tipo: "despesa",
            dataInicio: range.startISO,
            dataFim: range.endISO,
            idCategoria: categoria?.id
        )
        if transacoes.isEmpty {
            let extra = categoria.map { " em \($0.nome)" } ?? ""
            return "Não encontrei gastos \(range.spokenDescription())\(extra)."
        }

        let total = transacoes.reduce(DinixMoney.zero) { $0 + $1.valor }
        let extra = categoria.map { " com \($0.nome)" } ?? ""
        switch tipo {
        case .total:
            return "Você gastou \(total.formatted()) \(range.spokenDescription())\(extra)."
        case .maior:
            let maior = transacoes.max(by: { $0.valor.cents < $1.valor.cents })
            guard let maior else {
                return "Não encontrei gastos \(range.spokenDescription())\(extra)."
            }
            return "Sua maior despesa \(range.spokenDescription())\(extra) foi \(maior.descricao) de \(maior.valor.formatted())."
        case .lista:
            let linhas = transacoes.prefix(8).map { "\($0.descricao): \($0.valor.formatted())" }
            return "Seus gastos \(range.spokenDescription())\(extra):\n" + linhas.joined(separator: "\n")
        }
    }

    private static func comprasNoPeriodo(client: DinixAPIClient, range: DinixDateRange) async throws -> [DinixCompraRecord] {
        if range.isSingleDay {
            return try await client.compras(dias: [range.startISO])
        }
        if range.isCalendarMonth {
            return try await client.compras(mes: range.mes, ano: range.ano)
        }
        return try await client.compras().filter { compra in
            guard let data = compra.dataCompra else { return false }
            return data >= range.startISO && data <= range.endISO
        }
    }

    private static func formatarCompras(
        _ compras: [DinixCompraRecord],
        tipo: TipoConsultaGastos,
        periodo: DinixDateRange,
        contexto: String
    ) -> String {
        if compras.isEmpty {
            return "Não encontrei gastos \(contexto) \(periodo.spokenDescription())."
        }
        let total = compras.reduce(DinixMoney.zero) { $0 + $1.valorTotal }
        switch tipo {
        case .total:
            return "Você gastou \(total.formatted()) \(contexto) \(periodo.spokenDescription())."
        case .maior:
            let maior = compras.max(by: { $0.valorTotal.cents < $1.valorTotal.cents })
            return "Sua maior compra \(contexto) foi \(maior?.descricao ?? "compra") de \(maior?.valorTotal.formatted() ?? DinixMoney.zero.formatted())."
        case .lista:
            let linhas = compras.prefix(8).map { "\($0.descricao): \($0.valorTotal.formatted())" }
            return "Compras \(contexto) \(periodo.spokenDescription()):\n" + linhas.joined(separator: "\n")
        }
    }
}

@available(iOS 16.0, *)
struct ConsultarReceitasIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar receitas"
    static var description = IntentDescription("Consulta receitas e ganhos do Dinix em um período.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Período")
    var periodo: PeriodoConsulta?

    @Parameter(title: "Data inicial")
    var dataInicial: Date?

    @Parameter(title: "Data final")
    var dataFinal: Date?

    @Parameter(title: "Tipo da consulta")
    var tipo: TipoConsultaGastos?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar receitas \(\.$periodo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let range = DinixIntentSupport.range(
            periodo: periodo,
            dataInicial: dataInicial,
            dataFinal: dataFinal
        )
        let consulta = tipo ?? .total

        if range.isCalendarMonth, consulta == .total {
            let painel = try await client.painel(mes: range.mes, ano: range.ano)
            if painel.receitas.isZero {
                return .result(
                    value: "Não encontrei receitas \(range.spokenDescription()).",
                    dialog: DinixIntentSupport.dialog("Não encontrei receitas \(range.spokenDescription()).")
                )
            }
            let text = "Você recebeu \(painel.receitas.formatted()) \(range.spokenDescription())."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }

        let transacoes = try await client.transacoes(
            tipo: "receita",
            dataInicio: range.startISO,
            dataFim: range.endISO
        )
        if transacoes.isEmpty {
            let text = "Não encontrei receitas \(range.spokenDescription())."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        let total = transacoes.reduce(DinixMoney.zero) { $0 + $1.valor }
        let text: String
        switch consulta {
        case .total:
            text = "Você recebeu \(total.formatted()) \(range.spokenDescription())."
        case .maior:
            let maior = transacoes.max(by: { $0.valor.cents < $1.valor.cents })
            text = "Sua maior receita \(range.spokenDescription()) foi \(maior?.descricao ?? "receita") de \(maior?.valor.formatted() ?? DinixMoney.zero.formatted())."
        case .lista:
            text = "Suas receitas \(range.spokenDescription()):\n" +
                transacoes.prefix(8).map { "\($0.descricao): \($0.valor.formatted())" }.joined(separator: "\n")
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarSaldoIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar saldo"
    static var description = IntentDescription(
        "Consulta saldo das contas, disponível do mês ou um resumo das finanças no Dinix."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaSaldo?

    @Parameter(title: "Período")
    var periodo: PeriodoConsulta?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar \(\.$tipo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let consulta = tipo ?? .resumo
        let range = DinixDateRange.resolve(periodo: periodo?.dominio ?? .esteMes)
        let painel = try await client.painel(mes: range.mes, ano: range.ano)
        let patrimonio = try await client.patrimonio()

        let text: String
        switch consulta {
        case .saldoContas:
            text = "Seu saldo em contas é \(patrimonio.saldoContas.formatted())."
        case .disponivel:
            text = "O disponível \(range.spokenDescription()) é \(painel.disponivel.formatted()). Esse valor é receitas menos despesas e investimentos do mês."
        case .entrou:
            text = "Entrou \(painel.receitas.formatted()) \(range.spokenDescription())."
        case .saiu:
            text = "Saiu \(painel.despesas.formatted()) \(range.spokenDescription())."
        case .resumo:
            text = """
            Suas finanças \(range.spokenDescription()): saldo em contas \(patrimonio.saldoContas.formatted()), receitas \(painel.receitas.formatted()), despesas \(painel.despesas.formatted()) e disponível \(painel.disponivel.formatted()).
            """
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarContasPagarIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar contas a pagar"
    static var description = IntentDescription(
        "Consulta despesas recorrentes do Dinix: vencimentos, atrasadas e total a pagar."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaContasPagar?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar contas \(\.$tipo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let consulta = tipo ?? .pendentes
        let hoje = DinixDateRange.resolve(periodo: .hoje)
        let pendentes = try await client.gastosMensaisPendentes(data: hoje.startISO)
        let todos = try await client.gastosMensais()
        let painel = try await client.painel()
        let hojeDia = Calendar.current.component(.day, from: Date())

        let text: String
        switch consulta {
        case .pendentes:
            text = listar(pendentes, vazio: "Você não tem contas pendentes.")
        case .hoje:
            let itens = pendentes.filter { $0.diaVencimento == hojeDia }
            text = listar(itens, vazio: "Nenhuma conta vence hoje.")
        case .amanha:
            let amanha = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            let dia = Calendar.current.component(.day, from: amanha)
            let itens = todos.filter { $0.diaVencimento == dia && $0.ativo }
            text = listar(itens, vazio: "Nenhuma conta vence amanhã.")
        case .estaSemana:
            let semana = DinixDateRange.resolve(periodo: .estaSemana)
            let dias = Set(daysIn(semana).map { Calendar.current.component(.day, from: $0) })
            let itens = todos.filter { gasto in
                guard let dia = gasto.diaVencimento else { return false }
                return gasto.ativo && dias.contains(dia)
            }
            text = listar(itens, vazio: "Nenhuma conta vence esta semana.")
        case .atrasadas:
            let atrasadas = todos.filter { gasto in
                guard let dia = gasto.diaVencimento, gasto.ativo else { return false }
                return dia < hojeDia && pendentes.contains(where: { $0.id == gasto.id })
            }
            if atrasadas.isEmpty {
                text = "Você não tem contas atrasadas."
            } else {
                let total = atrasadas.reduce(DinixMoney.zero) { $0 + $1.valor }
                text = "Você tem \(atrasadas.count) conta(s) atrasada(s), total \(total.formatted())."
            }
        case .proxima:
            if let proxima = painel.proximosPagamentos.first(where: { $0.tipo == "despesa_recorrente" })
                ?? painel.proximosPagamentos.first {
                text = "Sua próxima conta é \(proxima.descricao) de \(proxima.valor.formatted())\(proxima.dataVencimento.map { " em \($0)" } ?? "")."
            } else {
                text = "Não encontrei a próxima conta a pagar."
            }
        case .total:
            let total = pendentes.reduce(DinixMoney.zero) { $0 + $1.valor }
            text = pendentes.isEmpty
                ? "Você não tem contas pendentes."
                : "Você tem \(total.formatted()) em contas para pagar."
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }

    private func listar(_ itens: [DinixGastoMensalRecord], vazio: String) -> String {
        if itens.isEmpty { return vazio }
        let linhas = itens.prefix(8).map { "\($0.nome): \($0.valor.formatted())" }
        return linhas.joined(separator: "\n")
    }

    private func daysIn(_ range: DinixDateRange) -> [Date] {
        var dates: [Date] = []
        var current = range.start
        let cal = Calendar.current
        while current <= range.end {
            dates.append(current)
            current = cal.date(byAdding: .day, value: 1, to: current) ?? range.end.addingTimeInterval(86_400)
        }
        return dates
    }
}

@available(iOS 16.0, *)
struct ConsultarAssinaturasIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar assinaturas"
    static var description = IntentDescription("Consulta assinaturas do Dinix, próximo vencimento e total mensal.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaAssinaturas?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar assinaturas \(\.$tipo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let consulta = tipo ?? .lista
        let text: String
        switch consulta {
        case .lista:
            let itens = try await client.assinaturas()
            text = itens.isEmpty
                ? "Você não tem assinaturas cadastradas."
                : "Suas assinaturas:\n" + itens.prefix(10).map { "\($0.nome): \($0.valor.formatted())" }.joined(separator: "\n")
        case .resumoMensal:
            let resumo = try await client.assinaturasResumo()
            text = "Você gasta \(resumo.totalMensal.formatted()) por mês com assinaturas."
        case .proxima:
            let resumo = try await client.assinaturasResumo()
            if let proxima = resumo.proximos.first {
                text = "Sua próxima assinatura é \(proxima.nome) de \(proxima.valor.formatted())\(proxima.data.map { " em \($0)" } ?? "")."
            } else {
                text = "Não encontrei a próxima assinatura."
            }
        case .vencemEssaSemana:
            let semana = DinixDateRange.resolve(periodo: .estaSemana)
            let itens = try await client.assinaturas().filter { assinatura in
                guard let data = assinatura.dataProximaCobranca else { return false }
                return data >= semana.startISO && data <= semana.endISO
            }
            text = itens.isEmpty
                ? "Nenhuma assinatura vence esta semana."
                : itens.map { "\($0.nome): \($0.valor.formatted())" }.joined(separator: "\n")
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarComprasIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar compras"
    static var description = IntentDescription("Consulta compras do Dinix, inclusive a maior compra e totais do período.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Período")
    var periodo: PeriodoConsulta?

    @Parameter(title: "Data inicial")
    var dataInicial: Date?

    @Parameter(title: "Data final")
    var dataFinal: Date?

    @Parameter(title: "Estabelecimento")
    var estabelecimento: LocalEntity?

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaCompras?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar compras \(\.$periodo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let range = DinixIntentSupport.range(
            periodo: periodo,
            dataInicial: dataInicial,
            dataFinal: dataFinal
        )
        var compras = try await client.compras()
        compras = compras.filter { compra in
            guard let data = compra.dataCompra else { return true }
            return data >= range.startISO && data <= range.endISO
        }
        if let estabelecimento {
            compras = compras.filter { $0.idLocal == estabelecimento.id }
        }
        let consulta = tipo ?? .ultimas
        let text: String
        switch consulta {
        case .ultimas:
            text = compras.isEmpty
                ? "Não encontrei compras \(range.spokenDescription())."
                : "Suas últimas compras:\n" + compras.prefix(8).map { "\($0.descricao): \($0.valorTotal.formatted())" }.joined(separator: "\n")
        case .total:
            let total = compras.reduce(DinixMoney.zero) { $0 + $1.valorTotal }
            text = compras.isEmpty
                ? "Não encontrei compras \(range.spokenDescription())."
                : "Você gastou \(total.formatted()) em compras \(range.spokenDescription())."
        case .maior:
            let maior = compras.max(by: { $0.valorTotal.cents < $1.valorTotal.cents })
            text = maior == nil
                ? "Não encontrei compras \(range.spokenDescription())."
                : "Sua maior compra foi \(maior!.descricao) de \(maior!.valorTotal.formatted())."
        case .parceladas:
            let parceladas = compras.filter(\.isParcelada)
            text = parceladas.isEmpty
                ? "Não encontrei compras parceladas \(range.spokenDescription())."
                : parceladas.prefix(8).map { "\($0.descricao): \($0.qtdParcelas)x de \($0.valorParcela.formatted())" }.joined(separator: "\n")
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarParcelasIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar parcelas"
    static var description = IntentDescription("Consulta compras parceladas do Dinix. O app não guarda o saldo restante de cada parcela.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaParcelas?

    @Parameter(title: "Compra")
    var compra: CompraEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar parcelas \(\.$tipo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let compras = try await client.compras().filter(\.isParcelada)
        if let compra, let alvo = compras.first(where: { $0.id == compra.id }) {
            let text = "A compra \(alvo.descricao) tem \(alvo.qtdParcelas) parcelas de \(alvo.valorParcela.formatted()). O Dinix não informa quantas já foram pagas."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }
        if let contexto = DinixSessionStore.shared.onScreenEntity(),
           contexto.type == "compra",
           let alvo = compras.first(where: { $0.id == contexto.id }) {
            let text = "Dessa compra ainda constam \(alvo.qtdParcelas) parcelas de \(alvo.valorParcela.formatted()). O Dinix não calcula o saldo restante das parcelas."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }

        let consulta = tipo ?? .lista
        let hoje = DinixDateRange.resolve(periodo: .hoje)
        let proximo = DinixDateRange.resolve(periodo: .esteMes).start
        let proximoMes = Calendar.current.date(byAdding: .month, value: 1, to: proximo) ?? proximo

        let text: String
        switch consulta {
        case .lista, .restanteDeclarado:
            text = compras.isEmpty
                ? "Você não tem compras parceladas."
                : "Compras parceladas:\n" + compras.prefix(8).map {
                    "\($0.descricao): \($0.qtdParcelas)x de \($0.valorParcela.formatted())"
                }.joined(separator: "\n")
        case .desteMes:
            let valor = compras.reduce(DinixMoney.zero) { $0 + $1.valorParcela }
            text = compras.isEmpty
                ? "Não há parcelas cadastradas."
                : "As parcelas cadastradas somam \(valor.formatted()) por mês. O Dinix não confirma quais vencem especificamente este mês."
        case .proximoMes:
            let valor = compras.reduce(DinixMoney.zero) { $0 + $1.valorParcela }
            text = compras.isEmpty
                ? "Não há parcelas cadastradas."
                : "As parcelas cadastradas somam \(valor.formatted()) ao mês. Não há no Dinix o vencimento individual da parcela de \(DinixDateRange.isoDate(proximoMes).prefix(7))."
        case .maisParcelas:
            let maior = compras.max(by: { $0.qtdParcelas < $1.qtdParcelas })
            text = maior == nil
                ? "Você não tem compras parceladas."
                : "A compra com mais parcelas é \(maior!.descricao), com \(maior!.qtdParcelas) vezes."
        case .vencePrimeiro:
            let primeira = compras
                .sorted { ($0.dataPrimeiraParcela ?? "") < ($1.dataPrimeiraParcela ?? "") }
                .first
            text = primeira == nil
                ? "Você não tem compras parceladas."
                : "A parcela que começa primeiro é de \(primeira!.descricao)\(primeira!.dataPrimeiraParcela.map { " em \($0)" } ?? "")."
        }
        _ = hoje
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarInvestimentosIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar investimentos"
    static var description = IntentDescription(
        "Consulta totais de investimento do Dinix. O app ainda não cadastra investimentos individualmente."
    )
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaInvestimentos?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar investimentos \(\.$tipo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let consulta = tipo ?? .total
        let text: String
        switch consulta {
        case .total:
            let patrimonio = try await client.patrimonio()
            text = "Você tem \(patrimonio.valorInvestimentos.formatted()) investidos."
        case .esteMes:
            let painel = try await client.painel()
            text = "Você investiu \(painel.investimentos.formatted()) este mês."
        case .mesPassado:
            let range = DinixDateRange.resolve(periodo: .mesPassado)
            let painel = try await client.painel(mes: range.mes, ano: range.ano)
            text = "Você investiu \(painel.investimentos.formatted()) no mês passado."
        case .esteAno:
            let transacoes = try await client.transacoes(
                tipo: "investimento",
                dataInicio: DinixDateRange.resolve(periodo: .esteAno).startISO,
                dataFim: DinixDateRange.resolve(periodo: .esteAno).endISO
            )
            let total = transacoes.reduce(DinixMoney.zero) { $0 + $1.valor }
            text = transacoes.isEmpty
                ? "Não encontrei movimentos de investimento este ano."
                : "Você movimentou \(total.formatted()) em investimentos este ano."
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarLocaisIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar estabelecimentos"
    static var description = IntentDescription("Consulta estabelecimentos do Dinix e quanto foi gasto em cada um.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Estabelecimento")
    var estabelecimento: LocalEntity?

    @Parameter(title: "Período")
    var periodo: PeriodoConsulta?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar gastos em \(\.$estabelecimento)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let range = DinixDateRange.resolve(periodo: periodo?.dominio ?? .esteMes)
        let compras = try await client.compras().filter { compra in
            guard let data = compra.dataCompra else { return true }
            return data >= range.startISO && data <= range.endISO
        }
        if let estabelecimento {
            let filtradas = compras.filter { $0.idLocal == estabelecimento.id }
            let total = filtradas.reduce(DinixMoney.zero) { $0 + $1.valorTotal }
            let text = filtradas.isEmpty
                ? "Não encontrei compras em \(estabelecimento.nome) \(range.spokenDescription())."
                : "Você gastou \(total.formatted()) em \(estabelecimento.nome) \(range.spokenDescription())."
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }

        var totais: [String: DinixMoney] = [:]
        var nomes: [String: String] = [:]
        let locais = try await client.locais()
        for local in locais { nomes[local.id] = local.nome }
        for compra in compras {
            guard let id = compra.idLocal else { continue }
            totais[id] = (totais[id] ?? .zero) + compra.valorTotal
        }
        let maior = totais.max(by: { $0.value.cents < $1.value.cents })
        let text: String
        if let maior {
            text = "O estabelecimento onde você mais gastou \(range.spokenDescription()) foi \(nomes[maior.key] ?? "um local") com \(maior.value.formatted())."
        } else {
            text = "Não encontrei gastos por estabelecimento \(range.spokenDescription())."
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}

@available(iOS 16.0, *)
struct ConsultarCategoriasIntent: AppIntent {
    static var title: LocalizedStringResource = "Consultar categorias"
    static var description = IntentDescription("Consulta gastos do Dinix agrupados por categoria.")
    static var openAppWhenRun = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Tipo")
    var tipo: TipoConsultaCategoria?

    @Parameter(title: "Categoria")
    var categoria: CategoriaEntity?

    @Parameter(title: "Período")
    var periodo: PeriodoConsulta?

    static var parameterSummary: some ParameterSummary {
        Summary("Consultar categorias \(\.$tipo)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let client = DinixIntentSupport.client()
        let range = DinixDateRange.resolve(periodo: periodo?.dominio ?? .esteMes)
        if let categoria {
            let text = try await ConsultarGastosIntent.consultar(
                client: client,
                range: range,
                categoria: categoria,
                estabelecimento: nil,
                tipo: .total
            )
            return .result(value: text, dialog: DinixIntentSupport.dialog(text))
        }

        let painel = try await client.painel(mes: range.mes, ano: range.ano)
        let consulta = tipo ?? .gastosPorCategoria
        let text: String
        switch consulta {
        case .gastosPorCategoria:
            text = painel.despesasPorCategoria.isEmpty
                ? "Não encontrei gastos por categoria \(range.spokenDescription())."
                : "Gastos por categoria \(range.spokenDescription()):\n" +
                painel.despesasPorCategoria.prefix(8).map { "\($0.nome): \($0.valor.formatted())" }.joined(separator: "\n")
        case .maiorCategoria:
            if let maior = painel.despesasPorCategoria.max(by: { $0.valor.cents < $1.valor.cents }) {
                text = "A categoria com maiores gastos \(range.spokenDescription()) é \(maior.nome), com \(maior.valor.formatted())."
            } else {
                text = "Não encontrei gastos por categoria \(range.spokenDescription())."
            }
        case .tipoMaisFrequente:
            if let maior = painel.despesasPorCategoria.max(by: { $0.valor.cents < $1.valor.cents }) {
                text = "O tipo de compra em que você mais gasta \(range.spokenDescription()) é \(maior.nome)."
            } else {
                text = "Não encontrei categorias \(range.spokenDescription())."
            }
        }
        return .result(value: text, dialog: DinixIntentSupport.dialog(text))
    }
}
