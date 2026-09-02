import AppIntents
import Foundation

@available(iOS 16.0, *)
enum PeriodoConsulta: String, AppEnum {
    case hoje
    case ontem
    case amanha
    case estaSemana
    case semanaPassada
    case esteMes
    case mesPassado
    case ultimos7Dias
    case ultimos30Dias
    case esteAno
    case anoPassado

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Período")

    static var caseDisplayRepresentations: [PeriodoConsulta: DisplayRepresentation] = [
        .hoje: "Hoje",
        .ontem: "Ontem",
        .amanha: "Amanhã",
        .estaSemana: "Esta semana",
        .semanaPassada: "Semana passada",
        .esteMes: "Este mês",
        .mesPassado: "Mês passado",
        .ultimos7Dias: "Últimos 7 dias",
        .ultimos30Dias: "Últimos 30 dias",
        .esteAno: "Este ano",
        .anoPassado: "Ano passado",
    ]

    var dominio: DinixPeriodo {
        DinixPeriodo(rawValue: rawValue) ?? .esteMes
    }
}

@available(iOS 16.0, *)
enum TipoConsultaGastos: String, AppEnum {
    case total
    case lista
    case maior

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tipo de consulta de gastos")

    static var caseDisplayRepresentations: [TipoConsultaGastos: DisplayRepresentation] = [
        .total: "Total",
        .lista: "Lista",
        .maior: "Maior gasto",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaSaldo: String, AppEnum {
    case saldoContas
    case disponivel
    case resumo
    case entrou
    case saiu

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tipo de saldo")

    static var caseDisplayRepresentations: [TipoConsultaSaldo: DisplayRepresentation] = [
        .saldoContas: "Saldo das contas",
        .disponivel: "Disponível no mês",
        .resumo: "Resumo financeiro",
        .entrou: "Quanto entrou",
        .saiu: "Quanto saiu",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaContasPagar: String, AppEnum {
    case pendentes
    case hoje
    case amanha
    case estaSemana
    case atrasadas
    case proxima
    case total

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Consulta de contas a pagar")

    static var caseDisplayRepresentations: [TipoConsultaContasPagar: DisplayRepresentation] = [
        .pendentes: "Pendentes",
        .hoje: "Vencem hoje",
        .amanha: "Vencem amanhã",
        .estaSemana: "Vencem esta semana",
        .atrasadas: "Atrasadas",
        .proxima: "Próxima conta",
        .total: "Total a pagar",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaAssinaturas: String, AppEnum {
    case lista
    case resumoMensal
    case proxima
    case vencemEssaSemana

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Consulta de assinaturas")

    static var caseDisplayRepresentations: [TipoConsultaAssinaturas: DisplayRepresentation] = [
        .lista: "Lista",
        .resumoMensal: "Gasto mensal",
        .proxima: "Próxima assinatura",
        .vencemEssaSemana: "Vencem esta semana",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaCompras: String, AppEnum {
    case ultimas
    case total
    case maior
    case parceladas

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Consulta de compras")

    static var caseDisplayRepresentations: [TipoConsultaCompras: DisplayRepresentation] = [
        .ultimas: "Últimas compras",
        .total: "Total em compras",
        .maior: "Maior compra",
        .parceladas: "Compras parceladas",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaParcelas: String, AppEnum {
    case restanteDeclarado
    case lista
    case desteMes
    case proximoMes
    case maisParcelas
    case vencePrimeiro

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Consulta de parcelas")

    static var caseDisplayRepresentations: [TipoConsultaParcelas: DisplayRepresentation] = [
        .restanteDeclarado: "Parcelas em aberto",
        .lista: "Lista de parceladas",
        .desteMes: "Parcelas deste mês",
        .proximoMes: "Parcelas do próximo mês",
        .maisParcelas: "Mais parcelas",
        .vencePrimeiro: "Vence primeiro",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaInvestimentos: String, AppEnum {
    case total
    case esteMes
    case mesPassado
    case esteAno

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Consulta de investimentos")

    static var caseDisplayRepresentations: [TipoConsultaInvestimentos: DisplayRepresentation] = [
        .total: "Total investido",
        .esteMes: "Investido este mês",
        .mesPassado: "Investido no mês passado",
        .esteAno: "Investido este ano",
    ]
}

@available(iOS 16.0, *)
enum TipoConsultaCategoria: String, AppEnum {
    case gastosPorCategoria
    case maiorCategoria
    case tipoMaisFrequente

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Consulta de categorias")

    static var caseDisplayRepresentations: [TipoConsultaCategoria: DisplayRepresentation] = [
        .gastosPorCategoria: "Gastos por categoria",
        .maiorCategoria: "Maior categoria",
        .tipoMaisFrequente: "Tipo mais frequente",
    ]
}

@available(iOS 16.0, *)
enum TipoRegistroExclusao: String, AppEnum {
    case compra
    case receita
    case gastoMensal
    case assinatura

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Tipo de registro")

    static var caseDisplayRepresentations: [TipoRegistroExclusao: DisplayRepresentation] = [
        .compra: "Compra ou despesa",
        .receita: "Receita",
        .gastoMensal: "Conta a pagar",
        .assinatura: "Assinatura",
    ]
}

@available(iOS 16.0, *)
enum FormaPagamentoSiri: String, AppEnum {
    case pix
    case dinheiro
    case cartaoDebito
    case cartaoCredito
    case transferencia
    case boleto

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Forma de pagamento")

    static var caseDisplayRepresentations: [FormaPagamentoSiri: DisplayRepresentation] = [
        .pix: "Pix",
        .dinheiro: "Dinheiro",
        .cartaoDebito: "Cartão de débito",
        .cartaoCredito: "Cartão de crédito",
        .transferencia: "Transferência",
        .boleto: "Boleto",
    ]

    var apiValue: String {
        switch self {
        case .pix: return "pix"
        case .dinheiro: return "dinheiro"
        case .cartaoDebito: return "cartao_debito"
        case .cartaoCredito: return "cartao_credito"
        case .transferencia: return "transferencia"
        case .boleto: return "boleto"
        }
    }
}
