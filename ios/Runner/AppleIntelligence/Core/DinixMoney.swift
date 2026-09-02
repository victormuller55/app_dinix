import Foundation

/// Representação monetária em centavos de Real para evitar erro de ponto flutuante.
struct DinixMoney: Equatable, Hashable, Sendable {
    let cents: Int

    static let zero = DinixMoney(cents: 0)
    static let currencyCode = "BRL"
    static let currencySymbol = "R$"

    init(cents: Int) {
        self.cents = cents
    }

    init(decimalString: String) {
        self.cents = Self.parseCents(decimalString)
    }

    init(jsonValue: Any?) {
        self.cents = Self.parseJSON(jsonValue)
    }

    /// Converte valor vindo de App Intent (`Double` é o tipo numérico estável do framework).
    init(intentValue: Double) {
        self.cents = Int((intentValue * 100.0).rounded())
    }

    var decimal: Decimal {
        Decimal(cents) / 100
    }

    var isZero: Bool { cents == 0 }

    static func + (lhs: DinixMoney, rhs: DinixMoney) -> DinixMoney {
        DinixMoney(cents: lhs.cents + rhs.cents)
    }

    static func - (lhs: DinixMoney, rhs: DinixMoney) -> DinixMoney {
        DinixMoney(cents: lhs.cents - rhs.cents)
    }

    func formatted() -> String {
        Self.formatter.string(from: decimal as NSDecimalNumber) ?? "R$ 0,00"
    }

    func apiString() -> String {
        let sign = cents < 0 ? "-" : ""
        let absolute = abs(cents)
        return "\(sign)\(absolute / 100).\(String(format: "%02d", absolute % 100))"
    }

    static func parseCents(_ raw: String) -> Int {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return 0 }

        let negative = trimmed.hasPrefix("-")
        var normalized = trimmed.replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: " ", with: "")
        if negative { normalized.removeFirst() }

        if normalized.contains(",") && normalized.contains(".") {
            normalized = normalized.replacingOccurrences(of: ".", with: "")
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        } else if normalized.contains(",") {
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        }

        let parts = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let whole = Int(parts.first ?? "0") ?? 0
        let fractionRaw = parts.count > 1 ? String(parts[1]) : "00"
        let fractionPadded = (fractionRaw + "00").prefix(2)
        let fraction = Int(fractionPadded) ?? 0
        let cents = whole * 100 + fraction
        return negative ? -cents : cents
    }

    private static func parseJSON(_ value: Any?) -> Int {
        switch value {
        case let number as NSNumber:
            return parseCents(number.stringValue)
        case let string as String:
            return parseCents(string)
        case let int as Int:
            return int * 100
        default:
            return 0
        }
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.currencySymbol = "\(currencySymbol) "
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
