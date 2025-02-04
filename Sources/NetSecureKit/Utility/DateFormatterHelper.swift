//
//  DateFormatterHelper.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 4.02.2025.
//

import Foundation

public struct DateFormatterHelper {
    
    static func dateFormatter(withFormat format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter
    }
    
    static func isValidSSLCertificateDate(issuedDate: Date, expiresDate: Date) -> Bool {
        return Date() >= issuedDate && Date() <= expiresDate
    }
}
