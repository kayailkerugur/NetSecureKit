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
    
    private let sslPinningEnabled: Bool
    private let certificateName: String

    public init(sslPinningEnabled: Bool = false, serverCertificateName: String) {
        self.sslPinningEnabled = sslPinningEnabled
        self.certificateName = serverCertificateName
    }
    
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard sslPinningEnabled else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let bundleCertificate = SSLHelper.fetchBundleSertificate(certificateName: certificateName) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let bundleCertificateData = SecCertificateCopyData(bundleCertificate) as Data
        let bundleCertificateHash = SSLHelper.sha256(data: bundleCertificateData)

        let serverCertificates = (0..<SecTrustGetCertificateCount(serverTrust)).compactMap {
            SecTrustGetCertificateAtIndex(serverTrust, $0)
        }

        for serverCertificate in serverCertificates {
            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
            let serverCertificateHash = SSLHelper.sha256(data: serverCertificateData)

            if serverCertificateHash == bundleCertificateHash {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
