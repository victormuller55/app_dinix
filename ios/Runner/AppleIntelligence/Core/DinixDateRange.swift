import Foundation

enum DinixPeriodo: String, CaseIterable {
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
    case personalizado
}

struct DinixDateRange: Equatable, Sendable {
    let start: Date
    let end: Date
    let periodo: DinixPeriodo

    var startISO: String { Self.isoDate(start) }
    var endISO: String { Self.isoDate(end) }

    var isSingleDay: Bool { startISO == endISO }

    var mes: Int { Calendar.current.component(.month, from: start) }
    var ano: Int { Calendar.current.component(.year, from: start) }

    var isCalendarMonth: Bool {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: start)),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
              let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return false
        }
        return startISO == Self.isoDate(monthStart) && endISO == Self.isoDate(monthEnd)
    }

    func spokenDescription() -> String {
        switch periodo {
        case .hoje: return "hoje"
        case .ontem: return "ontem"
        case .amanha: return "amanhã"
        case .estaSemana: return "esta semana"
        case .semanaPassada: return "na semana passada"
        case .esteMes: return "este mês"
        case .mesPassado: return "no mês passado"
        case .ultimos7Dias: return "nos últimos 7 dias"
        case .ultimos30Dias: return "nos últimos 30 dias"
        case .esteAno: return "este ano"
        case .anoPassado: return "no ano passado"
        case .personalizado:
            if isSingleDay {
                return "em \(Self.spokenDay(start))"
            }
            return "de \(Self.spokenDay(start)) a \(Self.spokenDay(end))"
        }
    }

    static func resolve(
        periodo: DinixPeriodo,
        dataInicial: Date? = nil,
        dataFinal: Date? = nil,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> DinixDateRange {
        var cal = calendar
        cal.timeZone = TimeZone.current
        let today = cal.startOfDay(for: now)

        func day(_ offset: Int) -> Date {
            cal.date(byAdding: .day, value: offset, to: today) ?? today
        }

        switch periodo {
        case .hoje:
            return DinixDateRange(start: today, end: today, periodo: .hoje)
        case .ontem:
            let yesterday = day(-1)
            return DinixDateRange(start: yesterday, end: yesterday, periodo: .ontem)
        case .amanha:
            let tomorrow = day(1)
            return DinixDateRange(start: tomorrow, end: tomorrow, periodo: .amanha)
        case .estaSemana:
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
            let end = cal.date(byAdding: .day, value: 6, to: start) ?? today
            return DinixDateRange(start: start, end: end, periodo: .estaSemana)
        case .semanaPassada:
            let thisWeek = resolve(periodo: .estaSemana, now: now, calendar: cal)
            let start = cal.date(byAdding: .day, value: -7, to: thisWeek.start) ?? today
            let end = cal.date(byAdding: .day, value: -7, to: thisWeek.end) ?? today
            return DinixDateRange(start: start, end: end, periodo: .semanaPassada)
        case .esteMes:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: today)) ?? today
            let end = lastDayOfMonth(containing: start, calendar: cal)
            return DinixDateRange(start: start, end: end, periodo: .esteMes)
        case .mesPassado:
            let thisMonth = resolve(periodo: .esteMes, now: now, calendar: cal)
            let start = cal.date(byAdding: .month, value: -1, to: thisMonth.start) ?? today
            let end = lastDayOfMonth(containing: start, calendar: cal)
            return DinixDateRange(start: start, end: end, periodo: .mesPassado)
        case .ultimos7Dias:
            return DinixDateRange(start: day(-6), end: today, periodo: .ultimos7Dias)
        case .ultimos30Dias:
            return DinixDateRange(start: day(-29), end: today, periodo: .ultimos30Dias)
        case .esteAno:
            let start = cal.date(from: DateComponents(year: cal.component(.year, from: today), month: 1, day: 1)) ?? today
            let end = cal.date(from: DateComponents(year: cal.component(.year, from: today), month: 12, day: 31)) ?? today
            return DinixDateRange(start: start, end: end, periodo: .esteAno)
        case .anoPassado:
            let year = cal.component(.year, from: today) - 1
            let start = cal.date(from: DateComponents(year: year, month: 1, day: 1)) ?? today
            let end = cal.date(from: DateComponents(year: year, month: 12, day: 31)) ?? today
            return DinixDateRange(start: start, end: end, periodo: .anoPassado)
        case .personalizado:
            let start = cal.startOfDay(for: dataInicial ?? today)
            let end = cal.startOfDay(for: dataFinal ?? dataInicial ?? today)
            if start <= end {
                return DinixDateRange(start: start, end: end, periodo: .personalizado)
            }
            return DinixDateRange(start: end, end: start, periodo: .personalizado)
        }
    }

    static func fromInterval(_ interval: DateInterval?, fallback: DinixPeriodo = .esteMes) -> DinixDateRange {
        guard let interval else {
            return resolve(periodo: fallback)
        }
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        let start = cal.startOfDay(for: interval.start)
        let endDate = interval.duration > 0
            ? cal.date(byAdding: .second, value: -1, to: interval.end) ?? interval.end
            : interval.end
        let end = cal.startOfDay(for: endDate)
        return DinixDateRange(start: start, end: end, periodo: .personalizado)
    }

    static func isoDate(_ date: Date, calendar: Calendar = .current) -> String {
        var cal = calendar
        cal.timeZone = TimeZone.current
        let parts = cal.dateComponents([.year, .month, .day], from: date)
        let year = parts.year ?? 1970
        let month = parts.month ?? 1
        let day = parts.day ?? 1
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func parseISO(_ value: String?) -> Date? {
        guard let value, value.count >= 10 else { return nil }
        let iso = String(value.prefix(10))
        let parts = iso.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else { return nil }
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal.date(from: DateComponents(year: year, month: month, day: day))
    }

    static func spokenDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func currentTimeHHmmss() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    private static func lastDayOfMonth(containing date: Date, calendar: Calendar) -> Date {
        guard let next = calendar.date(byAdding: .month, value: 1, to: date),
              let last = calendar.date(byAdding: .day, value: -1, to: next) else {
            return date
        }
        return last
    }
}
