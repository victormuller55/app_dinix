import XCTest
@testable import Runner

final class DinixConsultaLogicTests: XCTestCase {
    func testMensagemGastosVazia() {
        let range = DinixDateRange.resolve(periodo: .ontem)
        XCTAssertTrue(range.spokenDescription().contains("ontem"))
    }

    func testErroUsuarioAmigavelNaoExpoeStatus() {
        let erro = DinixAPIError.from(statusCode: 500, body: ["mensagem": "NullPointer"])
        XCTAssertEqual(erro, .unavailable)
        XCTAssertFalse(erro.userMessage.contains("NullPointer"))
    }

    func testSaldoNaoConfundeContaBancariaComContaAPagar() {
        let patrimonio = DinixPatrimonioRecord(DinixJSON([
            "saldo_contas": "1200.00",
            "valor_investimentos": "500.00",
            "dividas": "0",
            "patrimonio": "1700.00",
        ]))
        XCTAssertEqual(patrimonio.saldoContas.formatted(), "R$ 1.200,00")
        XCTAssertEqual(patrimonio.valorInvestimentos.formatted(), "R$ 500,00")
    }
}
