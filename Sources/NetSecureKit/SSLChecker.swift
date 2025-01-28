//
//  SSLChecker.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 21.01.2025.
//

import Foundation
import CommonCrypto
import Security

import Foundation

public final class SSLChecker: NSObject, URLSessionDelegate, @unchecked Sendable {
    private var logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            logger.log(message: "SSL Sertifika doğrulaması yapılamadı.")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust)).compactMap { index in
            SecTrustGetCertificateAtIndex(serverTrust, index)
        }
        
        guard let serverCertificate = serverCertificates.first else {
            logger.log(message: "SSL Sertifika bulunamadı")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
        let serverCertificateHash = SSLHelper.sha256(data: serverCertificateData)
        
        if let validityDates = SSLHelper.getCertificateValidity(from: serverCertificateData) {
            print("Issued On: \(validityDates.issuedOn)")
            print("Expires On: \(validityDates.expiresOn)")
        } else {
            logger.log(message: "Sertifika geçerlilik tarihleri alınamadı.")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        print("Sertifika SHA-256 Hash: \(serverCertificateHash)")
        
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
