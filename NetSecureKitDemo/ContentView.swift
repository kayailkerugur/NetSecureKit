//
//  ContentView.swift
//  NetSecureKitDemo
//
//  Created by İlker Kaya on 22.01.2025.
//

import SwiftUI
import NetSecureKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Button {
                    do {
                        let data = try JSONEncoder().encode(AuthModel())
                        var endpoint = ExampleEndpoint()
                        endpoint.body = data
                        NetworkManager.shared.request(endpoint: endpoint, responseType: AuthOutModel.self) { result in
                            switch result {
                            case .success(let posts):
                                print("Posts: \(String(describing: posts))")
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                   
//                    Task {
//                        do {
//                            try await SSLChecker.shared.checkURL(url: "https://www.youtube.com")
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }
                } label: {
                    Text("Test Et")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                NavigationLink {
                    LogListView()
                } label: {
                    Text("Logları Görüntüle")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

            }
        }
    }
}

struct ExampleEndpoint: Endpoint {
    var baseURL: String = ""
    var path: String = ""
    var method: HTTPMethod = .post
    var headers: [String : String]? = nil
    var queryParameters: [String : String]? = nil
    var body: Data? = nil
}


#Preview {
    ContentView()
}
