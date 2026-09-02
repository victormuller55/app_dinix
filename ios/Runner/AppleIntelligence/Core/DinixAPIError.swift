import Foundation

enum DinixAPIError: Error, Equatable, LocalizedError {
    case notAuthenticated
    case sessionExpired
    case unavailable
    case notFound
    case validation(String)
    case business(String)
    case empty
    case unsupported(String)
    case cancelled

    var errorDescription: String? { userMessage }

    var userMessage: String {
        switch self {
        case .notAuthenticated:
            return "Abra o Dinix e faça login para consultar seus dados."
        case .sessionExpired:
            return "Sua sessão do Dinix expirou. Abra o aplicativo e entre novamente."
        case .unavailable:
            return "Não consegui acessar seus dados do Dinix agora."
        case .notFound:
            return "Não encontrei esse registro no Dinix."
        case .validation(let message), .business(let message):
            return message.isEmpty ? "Não foi possível concluir essa ação no Dinix." : message
        case .empty:
            return "Não encontrei resultados para essa consulta."
        case .unsupported(let message):
            return message
        case .cancelled:
            return "Ação cancelada."
        }
    }

    static func from(statusCode: Int, body: [String: Any]?) -> DinixAPIError {
        let mensagem = (body?["mensagem"] as? String)
            ?? (body?["message"] as? String)
            ?? ""
        let codigo = (body?["erro"] as? String) ?? ""

        switch statusCode {
        case 401:
            return codigo.contains("token") ? .sessionExpired : .notAuthenticated
        case 404:
            return .notFound
        case 400:
            return .validation(friendlyValidation(body) ?? mensagem)
        case 409, 422:
            return .business(mensagem.isEmpty ? "Não foi possível concluir essa ação no Dinix." : mensagem)
        default:
            return .unavailable
        }
    }

    private static func friendlyValidation(_ body: [String: Any]?) -> String? {
        guard let campos = body?["erros_campos"] as? [String: Any] else { return nil }
        let first = campos.values.compactMap { $0 as? String }.first
        return first
    }
}
