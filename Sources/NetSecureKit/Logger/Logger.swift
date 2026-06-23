//
//  Logger.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 24.01.2025.
//

import Foundation

public struct LogEntry: Sendable {
    public let timestamp: Date
    public let functionName: String
    public let file: String
    public let message: String
    
    public init(
        timestamp: Date = Date(),
        functionName: String,
        file: String,
        message: String
    ) {
        self.timestamp = timestamp
        self.functionName = functionName
        self.file = file
        self.message = message
    }
}

public actor NetSecureLogger {
    
    public static let shared = NetSecureLogger()
    
    private var logs: [LogEntry] = []
    private let maxLogCount: Int = 1000
    
    private init() {}
    
    public func addLog(
        message: String,
        functionName: String = #function,
        file: String = #fileID
    ) {
        let log = LogEntry(
            functionName: functionName,
            file: file,
            message: message
        )
        
        logs.append(log)
        
        if logs.count > maxLogCount {
            logs.removeFirst()
        }
    }
    
    public func getLogs() -> [LogEntry] {
        logs
    }
    
    public func clearLogs() {
        logs.removeAll()
    }
    
    public func logs(for functionName: String) -> [LogEntry] {
        logs.filter { $0.functionName == functionName }
    }
    
    public func exportLogs() -> String {
        logs.map { log in
            "[\(Self.formatDate(log.timestamp))] \(log.file) - \(log.functionName): \(log.message)"
        }
        .joined(separator: "\n")
    }
    
    private nonisolated static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
