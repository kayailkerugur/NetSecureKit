//
//  SSLChecker.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 21.01.2025.
//

import Foundation
import CommonCrypto
import Security

public class SSLChecker: NSObject, URLSessionDelegate {
    public static let shared = SSLChecker()
    private override init() { }
    
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            Logger.shared.log(message: "SSL Sertifika doğrulaması yapılamadı.")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust)).compactMap { index in
            SecTrustGetCertificateAtIndex(serverTrust, index)
        }
        
        guard let serverCertificate = serverCertificates.first else {
            Logger.shared.log(message: "SSL Sertifika bulunamadı")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
        let serverCertificateHash = SSLHelper.sha256(data: serverCertificateData)
        
        if let validityDates = SSLHelper.getCertificateValidity(from: serverCertificateData) {
            print("Issued On: \(validityDates.issuedOn)")
            print("Expires On: \(validityDates.expiresOn)")
        } else {
            Logger.shared.log(message: "Sertifika geçerlilik tarihleri alınamadı.")
        }
        
        print("Sertifika SHA-256 Hash: \(serverCertificateHash)")
        
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    // MARK: For manuel check process
    public func checkURL(url: String) async throws {
        let session = createSession()
        let url = URL(string: url)!
        
        do {
            let (_, response) = try await session.data(for: URLRequest(url: url))
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Başarılı! SSL -> HTTP Durum Kodu: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    Logger.shared.log(message: "SSL Sertifikası bulunamadı")
                    throw NetworkError.sslError
                }
            } else {
                Logger.shared.log(message: "SSL kısmında bilinmeyen hata meydana geldi")
                throw NetworkError.unknownError
            }
        } catch {
            Logger.shared.log(message: "SSL Sertifikası bulunamadı")
            throw NetworkError.sslError
        }
    }
}
