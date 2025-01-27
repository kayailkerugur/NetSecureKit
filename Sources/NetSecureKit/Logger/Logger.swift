//
//  Logger.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 24.01.2025.
//

import Foundation

public final class Logger {
    public struct LogEntry {
        public let timestamp: String
        public let functionName: String
        public let message: String
    }
    
    private var logs: [LogEntry] = []
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    public init() {}
    
    public func log(functionName: String = #function, message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = LogEntry(timestamp: timestamp, functionName: functionName, message: message)
        
        self.logs.append(logEntry)
    }
    
    public func getLogs() -> [LogEntry] {
        return logs
    }
    
    public func clearLogs() {
        self.logs.removeAll()
    }
}
