//
//  SSLChecker.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 21.01.2025.
//

import Foundation
import CommonCrypto
import Security

public class SSLChecker: NSObject, @preconcurrency URLSessionDelegate, @unchecked Sendable {
    public static let shared = SSLChecker()
    private override init() { }
    
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    @MainActor public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
        
        print("Sertifika SHA-256 Hash: \(serverCertificateHash)")
        
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    // MARK: For manuel check process
//    public func checkURL(url: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
//        let session = createSession()
//        guard let url = URL(string: url) else {
//            Logger.shared.log(message: "Geçersiz URL")
//            completion(.failure(.unknownError))
//            return
//        }
//        
//        let task = session.dataTask(with: URLRequest(url: url)) { data, response, error in
//            if let error = error {
//                Logger.shared.log(message: "SSL Sertifikası bulunamadı. Hata: \(error.localizedDescription)")
//                completion(.failure(.sslError))
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                Logger.shared.log(message: "SSL kısmında bilinmeyen hata meydana geldi")
//                completion(.failure(.unknownError))
//                return
//            }
//            
//            if httpResponse.statusCode == 200 {
//                print("Başarılı! SSL -> HTTP Durum Kodu: \(httpResponse.statusCode)")
//                completion(.success(()))
//            } else {
//                Logger.shared.log(message: "SSL Sertifikası bulunamadı. HTTP Durum Kodu: \(httpResponse.statusCode)")
//                completion(.failure(.sslError))
//            }
//        }
//        
//        task.resume()
//    }

}
