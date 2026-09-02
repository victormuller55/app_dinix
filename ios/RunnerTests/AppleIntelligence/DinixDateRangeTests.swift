import XCTest
@testable import Runner

final class DinixDateRangeTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Sao_Paulo") ?? .current
        cal.firstWeekday = 1
        return cal
    }

    private var wednesday: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 2))!
    }

    func testHojeEOntem() {
        let hoje = DinixDateRange.resolve(periodo: .hoje, now: wednesday, calendar: calendar)
        XCTAssertEqual(hoje.startISO, "2026-09-02")
        XCTAssertEqual(hoje.endISO, "2026-09-02")

        let ontem = DinixDateRange.resolve(periodo: .ontem, now: wednesday, calendar: calendar)
        XCTAssertEqual(ontem.startISO, "2026-09-01")
        XCTAssertEqual(ontem.endISO, "2026-09-01")
    }

    func testEsteMesEMesPassado() {
        let mes = DinixDateRange.resolve(periodo: .esteMes, now: wednesday, calendar: calendar)
        XCTAssertEqual(mes.startISO, "2026-09-01")
        XCTAssertEqual(mes.endISO, "2026-09-30")
        XCTAssertTrue(mes.isCalendarMonth)

        let passado = DinixDateRange.resolve(periodo: .mesPassado, now: wednesday, calendar: calendar)
        XCTAssertEqual(passado.startISO, "2026-08-01")
        XCTAssertEqual(passado.endISO, "2026-08-31")
    }

    func testUltimos7E30Dias() {
        let sete = DinixDateRange.resolve(periodo: .ultimos7Dias, now: wednesday, calendar: calendar)
        XCTAssertEqual(sete.startISO, "2026-08-27")
        XCTAssertEqual(sete.endISO, "2026-09-02")

        let trinta = DinixDateRange.resolve(periodo: .ultimos30Dias, now: wednesday, calendar: calendar)
        XCTAssertEqual(trinta.startISO, "2026-08-04")
        XCTAssertEqual(trinta.endISO, "2026-09-02")
    }

    func testEsteAno() {
        let ano = DinixDateRange.resolve(periodo: .esteAno, now: wednesday, calendar: calendar)
        XCTAssertEqual(ano.startISO, "2026-01-01")
        XCTAssertEqual(ano.endISO, "2026-12-31")
    }

    func testPersonalizadoInverteIntervalo() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 9, day: 10))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1))!
        let range = DinixDateRange.resolve(
            periodo: .personalizado,
            dataInicial: start,
            dataFinal: end,
            now: wednesday,
            calendar: calendar
        )
        XCTAssertEqual(range.startISO, "2026-09-01")
        XCTAssertEqual(range.endISO, "2026-09-10")
    }
}
