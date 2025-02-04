//
//  SSLChecker.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 21.01.2025.
//

import Foundation
import CommonCrypto
import Security

public final class SSLChecker: NSObject, URLSessionDelegate, @unchecked Sendable {
    
    private var sslPinningEnabled: Bool = false
    
    private var certificateName: String = ""

    public init(sslPinningEnabled: Bool = false, serverCertificateName: String) {
        self.sslPinningEnabled = sslPinningEnabled
        self.certificateName = serverCertificateName
    }
    
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if sslPinningEnabled {
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                CapsulateLogger.addLog(functionName: #function, message: "SSL Sertifika doğrulaması yapılamadı.")

                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust)).compactMap { index in
                SecTrustGetCertificateAtIndex(serverTrust, index)
            }
            
            for serverCertificate in serverCertificates {
                
                guard let bundleCertificate = SSLHelper.fetchBundleSertificate(certificateName: certificateName) else  {
                    CapsulateLogger.addLog(functionName: #function, message: "Bundle'da SSL Sertifika bulunamadı")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                            
                let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
                let serverCertificateHash = SSLHelper.sha256(data: serverCertificateData)
                
                let bundleCertificateData = SecCertificateCopyData(bundleCertificate) as Data
                let bundleCertificateHash = SSLHelper.sha256(data: bundleCertificateData)
                
                if let validityDates = SSLHelper.getCertificateValidity(from: serverCertificateData) {
                    print("Issued On: \(validityDates.issuedOn)")
                    print("Expires On: \(validityDates.expiresOn)")
                    if !DateFormatterHelper.isValidSSLCertificateDate(issuedDate: validityDates.issuedOn, expiresDate: validityDates.expiresOn) {
                        CapsulateLogger.addLog(functionName: #function, message: "Sertifika süresi geçmiş")
                        completionHandler(.cancelAuthenticationChallenge, nil)
                        return
                    }
                } else {
                    CapsulateLogger.addLog(functionName: #function, message: "Sertifika geçerlilik tarihleri alınamadı.")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                
                if let validityDates = SSLHelper.getCertificateValidity(from: bundleCertificateData) {
                    print("Bundle Issued On: \(validityDates.issuedOn)")
                    print("Bundle Expires On: \(validityDates.expiresOn)")
                    if !DateFormatterHelper.isValidSSLCertificateDate(issuedDate: validityDates.issuedOn, expiresDate: validityDates.expiresOn) {
                        CapsulateLogger.addLog(functionName: #function, message: "Bundle Sertifika süresi geçmiş")
                        completionHandler(.cancelAuthenticationChallenge, nil)
                        return
                    }
                } else {
                    CapsulateLogger.addLog(functionName: #function, message: "Bundle Sertifika geçerlilik tarihleri alınamadı.")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                
                print("Sertifika SHA-256 Hash: \(serverCertificateHash)")
                print("Bundle Sertifika SHA-256 Hash: \(bundleCertificateHash)")
                
                if serverCertificateHash == bundleCertificateHash {
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                    return
                } else  {
                    CapsulateLogger.addLog(functionName: #function, message: "Bundle sertifikası ile server sertifikası uyuşmadı.")
                }
            }
            
            completionHandler(.cancelAuthenticationChallenge, nil)
            CapsulateLogger.addLog(functionName: #function, message: "Sertifika geçerli değil")
        } else {
            completionHandler(.useCredential, nil)
        }
    }
}
