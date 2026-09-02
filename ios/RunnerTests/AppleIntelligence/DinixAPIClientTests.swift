import XCTest
@testable import Runner

private final class MockHTTP: DinixHTTPPerforming, @unchecked Sendable {
    var statusCode = 200
    var body: [String: Any] = [:]
    var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        let data = try JSONSerialization.data(withJSONObject: body)
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (data, response)
    }
}

private final class UnavailableHTTP: DinixHTTPPerforming, @unchecked Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.notConnectedToInternet)
    }
}

final class DinixAPIClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        DinixSessionStore.shared.saveSession(
            token: "token-teste",
            userId: "user-1",
            authDay: DinixSessionStore.todayKey(),
            deviceId: "device-1",
            apiBaseURL: "https://dinix.api.convertix.net.br",
            clientId: "dinix-mobile",
            clientSecret: "dinix-mobile-client",
            appVersion: "1.0.0",
            biometriaHabilitada: false
        )
    }

    override func tearDown() {
        DinixSessionStore.shared.clearSession()
        super.tearDown()
    }

    func testGastosDeHojeUsaPainel() async throws {
        let http = MockHTTP()
        http.body = [
            "mes": 9,
            "ano": 2026,
            "receitas": ["total": "0.00"],
            "despesas": ["total": "187.50"],
            "investimentos": "0.00",
            "disponivel": "0.00",
        ]
        let client = DinixAPIClient(http: http)
        let range = DinixDateRange.resolve(periodo: .hoje)
        _ = range
        let painel = try await client.painel(mes: 9, ano: 2026)
        XCTAssertEqual(painel.despesas.cents, 18750)
        XCTAssertTrue(http.lastRequest?.url?.path.contains("/painel") == true)
    }

    func testUsuarioNaoAutenticado() async {
        DinixSessionStore.shared.clearSession()
        let client = DinixAPIClient(http: MockHTTP())
        do {
            _ = try await client.painel()
            XCTFail("deveria falhar sem sessão")
        } catch let error as DinixAPIError {
            XCTAssertEqual(error, .notAuthenticated)
            XCTAssertEqual(error.userMessage, "Abra o Dinix e faça login para consultar seus dados.")
        } catch {
            XCTFail("erro inesperado")
        }
    }

    func testTokenExpirado401() async {
        let http = MockHTTP()
        http.statusCode = 401
        http.body = ["erro": "token_invalido", "mensagem": "não autorizado"]
        let client = DinixAPIClient(http: http)
        do {
            _ = try await client.painel()
            XCTFail("deveria falhar com 401")
        } catch let error as DinixAPIError {
            XCTAssertEqual(error, .sessionExpired)
        } catch {
            XCTFail("erro inesperado")
        }
    }

    func testAPIIndisponivel() async {
        let client = DinixAPIClient(http: UnavailableHTTP())
        do {
            _ = try await client.painel()
            XCTFail("deveria falhar sem rede")
        } catch let error as DinixAPIError {
            XCTAssertEqual(error, .unavailable)
            XCTAssertEqual(error.userMessage, "Não consegui acessar seus dados do Dinix agora.")
        } catch {
            XCTFail("erro inesperado")
        }
    }

    func testErroBackendValidation() async {
        let http = MockHTTP()
        http.statusCode = 400
        http.body = [
            "erro": "erro_validacao",
            "mensagem": "Dados inválidos",
            "erros_campos": ["valor": "não deve estar em branco"],
        ]
        let client = DinixAPIClient(http: http)
        do {
            _ = try await client.criarReceita(
                descricao: "Salário",
                valor: .zero,
                data: "2026-09-02",
                idCategoria: nil,
                idConta: nil
            )
            XCTFail("deveria falhar")
        } catch let error as DinixAPIError {
            XCTAssertEqual(error.userMessage, "não deve estar em branco")
        } catch {
            XCTFail("erro inesperado")
        }
    }

    func testNenhumResultado() async throws {
        let http = MockHTTP()
        http.body = ["itens": [], "num_pag": 1, "max_pag": 0, "max_itens": 0]
        let client = DinixAPIClient(http: http)
        let transacoes = try await client.transacoes(tipo: "despesa", dataInicio: "2026-09-02", dataFim: "2026-09-02")
        XCTAssertTrue(transacoes.isEmpty)
    }

    func testCriarDespesaEnviaPayloadDaAPI() async throws {
        let http = MockHTTP()
        http.body = ["id": "c1", "descricao": "Supermercado", "valor_total": "50.00"]
        let client = DinixAPIClient(http: http)
        _ = try await client.criarCompra(
            descricao: "Supermercado",
            valor: DinixMoney(decimalString: "50.00"),
            data: "2026-09-02",
            idCategoria: nil,
            idLocal: nil,
            formaPagamento: "pix",
            idConta: "conta-1",
            idCartao: nil,
            parcelas: 1
        )
        XCTAssertEqual(http.lastRequest?.httpMethod, "POST")
        XCTAssertTrue(http.lastRequest?.url?.path.contains("/compras") == true)
        XCTAssertEqual(http.lastRequest?.value(forHTTPHeaderField: "autorizacao"), "Bearer token-teste")
    }
}
