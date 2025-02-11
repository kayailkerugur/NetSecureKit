//
//  SSLHelper.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 23.01.2025.
//

import Foundation
import Security
import CommonCrypto
import OpenSSL

public struct SSLHelper {
    static func getCertificateValidity(from certData: Data) -> (issuedOn: Date, expiresOn: Date)? {
        
        var validityDates: (issuedOn: Date, expiresOn: Date)?

        certData.withUnsafeBytes { rawBufferPointer in
            guard let baseAddress = rawBufferPointer.baseAddress else {
                print("Sertifika verisine erişilemedi.")
                return
            }

            let bio = BIO_new_mem_buf(baseAddress, Int32(certData.count))
            defer { BIO_free(bio) }

            guard let x509 = d2i_X509_bio(bio, nil) else {
                print("Sertifika OpenSSL X509 formatına dönüştürülemedi.")
                return
            }
            defer { X509_free(x509) }

            if let notBefore = X509_get0_notBefore(x509),
               let notAfter = X509_get0_notAfter(x509) {
                if let notBeforeDate = ASN1_TIME_to_date(notBefore),
                   let notAfterDate = ASN1_TIME_to_date(notAfter) {
                    validityDates = (issuedOn: notBeforeDate, expiresOn: notAfterDate)
                }
            } else {
                print("Geçerlilik tarihleri alınamadı.")
            }
        }
        
        return validityDates
    }

    static private func ASN1_TIME_to_date(_ time: UnsafePointer<ASN1_TIME>?) -> Date? {
        guard let time = time else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var year: Int32 = 0, month: Int32 = 0, day: Int32 = 0, hour: Int32 = 0, minute: Int32 = 0, second: Int32 = 0
        if ASN1_TIME_to_tm(time, &year, &month, &day, &hour, &minute, &second) != 0 {
            var dateComponents = DateComponents()
            dateComponents.year = Int(year)
            dateComponents.month = Int(month)
            dateComponents.day = Int(day)
            dateComponents.hour = Int(hour)
            dateComponents.minute = Int(minute)
            dateComponents.second = Int(second)

            return calendar.date(from: dateComponents)
        }
        return nil
    }

    static private func ASN1_TIME_to_tm(_ time: UnsafePointer<ASN1_TIME>, _ year: inout Int32, _ month: inout Int32, _ day: inout Int32, _ hour: inout Int32, _ minute: inout Int32, _ second: inout Int32) -> Int32 {
        var tm = tm()
        let result = OpenSSL.ASN1_TIME_to_tm(time, &tm)
        if result != 0 {
            year = tm.tm_year + 1900
            month = tm.tm_mon + 1
            day = tm.tm_mday
            hour = tm.tm_hour
            minute = tm.tm_min
            second = tm.tm_sec
        }
        return result
    }
    
    static func getCertificateData(from certificate: SecCertificate) -> Data? {
        return SecCertificateCopyData(certificate) as Data
    }
    
    static func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    static func fetchBundleSertificate(certificateName: String) -> SecCertificate? {
        if let certificateURL = Bundle.main.url(forResource: certificateName, withExtension: "der") {
            do {
                let certificateData = try Data(contentsOf: certificateURL)
                
                if let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
                    return certificate
                } else {
                    CapsulateLogger.addLog(functionName: #function, message: "Sertifika oluşturulamadı.")
                    return nil
                }
            } catch {
                CapsulateLogger.addLog(functionName: #function, message: "Sertifika dosyası okunurken hata oluştu: \(error)")
                return nil
            }
        } else {
            CapsulateLogger.addLog(functionName: #function, message: "Sertifika dosyası bulunamadı.")
            return nil
        }
    }
}

