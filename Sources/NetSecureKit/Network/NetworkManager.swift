//
//  NetworkManager.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 22.01.2025.
//

import Foundation

public final class NetworkManager: @unchecked Sendable {
    private var sslPinnig: Bool = false
    
    private var certificateName: String = ""
    
    public init(certificateName: String = "") {
        self.sslPinnig = true
        self.certificateName = certificateName
    }
    
    public func setSSLPinning(status: Bool) {
        self.sslPinnig = status
    }
    
    public func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping @Sendable (Result<T, NetworkError>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest()
            
            CapsulateLogger.addLog(functionName: #function, message: "\(request.url?.absoluteString ?? "") linkine ağ isteği gönderildi")

            
            let task = SSLChecker(sslPinningEnabled: sslPinnig, serverCertificateName: certificateName).createSession().dataTask(with: request) { data, response, error in
                
                if let error = error {
                    CapsulateLogger.addLog(functionName: #function, message: "Hata meydana geldi: \(error.localizedDescription)")
                    completion(.failure(.custom(error)))
                    return
                }
                
                guard let data = data else {
                    CapsulateLogger.addLog(functionName: #function, message: "Data bulunamadı")

                    completion(.failure(.noData))
                    return
                }
                
                do {
                    CapsulateLogger.addLog(functionName: #function, message: "Gelen veri: \(String(data: data, encoding: .utf8) ?? "Veri okunamadı")")
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    CapsulateLogger.addLog(functionName: #function, message: "Veri alındı ve başarıyla çözümlendi")

                    completion(.success(decodedResponse))
                } catch {
                    CapsulateLogger.addLog(functionName: #function, message: "Decoding sırasında hata: \(error.localizedDescription)")

                    completion(.failure(.decodingError))
                }
            }
            
            task.resume()
        } catch {
            CapsulateLogger.addLog(functionName: #function, message: "İstek oluşturulurken hata: \(error.localizedDescription)")
            completion(.failure(.custom(error)))
        }
    }
}
