//
//  SSLChecker.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 21.01.2025.
//

import Foundation
import CommonCrypto

public class SSLChecker: NSObject, URLSessionDelegate {
    public static let shared = SSLChecker()
    private override init() { }
    
    func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            print("Sertifika doğrulaması yapılamadı.")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust)).compactMap { index in
            SecTrustGetCertificateAtIndex(serverTrust, index)
        }
        
        guard let serverCertificate = serverCertificates.first else {
            print("Sertifika bulunamadı.")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
        let serverCertificateHash = sha256(data: serverCertificateData)
        
        print("Sertifika SHA-256 Hash: \(serverCertificateHash)")
        
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    private func sha256(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).map { String(format: "%02hhx", $0) }.joined()
    }
    
    public func checkURL(url: String) async throws {
        let session = createSession()
        let url = URL(string: url)!
        
        do {
            let (_, response) = try await session.data(for: URLRequest(url: url))

            if let httpResponse = response as? HTTPURLResponse {
                print("Başarılı! SSL -> HTTP Durum Kodu: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    throw NetworkError.sslError
                }
            } else {
                throw NetworkError.unknownError
            }
        } catch {
            throw NetworkError.sslError
        }
    }
}
