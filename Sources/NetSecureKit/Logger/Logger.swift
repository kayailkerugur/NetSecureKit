//
//  Logger.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 24.01.2025.
//

import Foundation

public final class Logger: @unchecked Sendable {
    public struct LogEntry : Sendable{
        public let timestamp: String
        public let functionName: String
        public let message: String
    }
    
    public static let shared = Logger()
    
    private var logs: [LogEntry] = []
    private let queue = DispatchQueue(label: "com.kayailker.logger", attributes: .concurrent)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private init() {}
    
    /// Log mesajını ekler.
    public func log(functionName: String = #function, message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = LogEntry(timestamp: timestamp, functionName: functionName, message: message)
        
        queue.async(flags: .barrier) { [weak self] in
            self?.logs.append(logEntry)
        }
    }
    
    /// Tüm logları döner.
    public func getLogs() -> [LogEntry] {
        var currentLogs: [LogEntry] = []
        queue.sync {
            currentLogs = logs
        }
        return currentLogs
    }
    
    /// Tüm logları temizler.
    public func clearLogs() {
        queue.async(flags: .barrier) { [weak self] in
            self?.logs.removeAll()
        }
    }
}
