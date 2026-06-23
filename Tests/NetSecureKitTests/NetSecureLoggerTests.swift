//
//  NetSecureLoggerTests.swift
//  NetSecureKit
//
//  Created by Ilker Ugur Kaya on 23.06.2026.
//

import XCTest
@testable import NetSecureKit

final class NetSecureLoggerTests: XCTestCase {

    func testAddLog() async {
        await NetSecureLogger.shared.clearLogs()

        await NetSecureLogger.shared.addLog(
            message: "Test message",
            functionName: "testFunction",
            file: "TestFile.swift"
        )

        let logs = await NetSecureLogger.shared.getLogs()

        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.message, "Test message")
        XCTAssertEqual(logs.first?.functionName, "testFunction")
        XCTAssertEqual(logs.first?.file, "TestFile.swift")
    }

    func testClearLogs() async {
        await NetSecureLogger.shared.clearLogs()

        await NetSecureLogger.shared.addLog(
            message: "Temporary log"
        )

        await NetSecureLogger.shared.clearLogs()

        let logs = await NetSecureLogger.shared.getLogs()

        XCTAssertTrue(logs.isEmpty)
    }

    func testExportLogs() async {
        await NetSecureLogger.shared.clearLogs()

        await NetSecureLogger.shared.addLog(
            message: "Export test",
            functionName: "exportTest",
            file: "LoggerTests.swift"
        )

        let output = await NetSecureLogger.shared.exportLogs()

        XCTAssertTrue(output.contains("Export test"))
        XCTAssertTrue(output.contains("exportTest"))
        XCTAssertTrue(output.contains("LoggerTests.swift"))
    }
}
