//
//  Logger.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 24.01.2025.
//

import Foundation

public final class Logger {
    public let timestamp: String?
    public let functionName: String?
    public let message: String?
    
    public init(functionName: String? = nil, message: String? = nil) {
        self.timestamp = dateFormatter.string(from: Date())
        self.functionName = functionName
        self.message = message
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

actor CapsulateLogger {
    static var logs: [Logger] = []

    static func addLog(functionName: String, message: String) {
        logs.append(Logger(functionName: functionName, message: message))
    }

    static func clearLogs() {
        logs.removeAll()
    }

    static func getLogs() -> [Logger] {
        return logs
    }
}
