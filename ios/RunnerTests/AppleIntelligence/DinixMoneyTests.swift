import XCTest
@testable import Runner

final class DinixMoneyTests: XCTestCase {
    func testIntentDoubleRoundsToCents() {
        XCTAssertEqual(DinixMoney(intentValue: 187.50).cents, 18750)
        XCTAssertEqual(DinixMoney(intentValue: 10.1).cents, 1010)
        XCTAssertEqual(DinixMoney(intentValue: 0).cents, 0)
    }

    func testParseDecimalString() {
        XCTAssertEqual(DinixMoney(decimalString: "187.50").cents, 18750)
        XCTAssertEqual(DinixMoney(decimalString: "187,50").cents, 18750)
        XCTAssertEqual(DinixMoney(decimalString: "R$ 1.234,56").cents, 123456)
        XCTAssertEqual(DinixMoney(decimalString: "50").cents, 5000)
    }

    func testSumDoesNotUseDouble() {
        let total = DinixMoney(decimalString: "10.10") + DinixMoney(decimalString: "20.20")
        XCTAssertEqual(total.cents, 3030)
        XCTAssertEqual(total.formatted(), "R$ 30,30")
    }

    func testApiString() {
        XCTAssertEqual(DinixMoney(cents: 18750).apiString(), "187.50")
        XCTAssertEqual(DinixMoney.zero.apiString(), "0.00")
    }

    func testJSONNumberAndString() {
        XCTAssertEqual(DinixMoney(jsonValue: "100.00").cents, 10000)
        XCTAssertEqual(DinixMoney(jsonValue: NSNumber(value: 50.5)).cents, 5050)
    }
}
