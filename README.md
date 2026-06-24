NetSecureKit

A lightweight, secure, and modern networking library for iOS built with Swift.

NetSecureKit simplifies network communication while providing features such as SSL Pinning, Async/Await support, response validation, raw data handling, and built-in logging.

Features

* SSL Pinning Support
* Async/Await Networking
* Completion Handler Networking
* HTTP Status Code Validation
* Raw Data Requests
* Empty Response Handling
* Thread-Safe Logging System
* Codable Request/Response Support
* Lightweight Architecture
* Swift Package Manager Support

Installation

Swift Package Manager

Add the package dependency to your project:

dependencies: [
    .package(
        url: "https://github.com/kayailkerugur/NetSecureKit.git",
        from: "1.2.0"
    )
]

Or add it directly from Xcode:

1. File
2. Add Package Dependencies
3. Paste:

https://github.com/kayailkerugur/NetSecureKit.git

Quick Start

Create an Endpoint

import NetSecureKit
let endpoint = EndpointModel(
    baseURL: "https://jsonplaceholder.typicode.com",
    path: "/posts/1",
    method: .get
)

Define Response Model

struct PostResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

Standard Request

let manager = NetworkManager()
manager.request(
    endpoint: endpoint,
    responseType: PostResponse.self
) { result in
    
    switch result {
    case .success(let response):
        print(response)
        
    case .failure(let error):
        print(error)
    }
}

Async/Await Support

let manager = NetworkManager()
let result = await manager.requestAsync(
    endpoint: endpoint,
    responseType: PostResponse.self
)
switch result {
case .success(let response):
    print(response)
case .failure(let error):
    print(error)
}

HTTP Status Code Validation

manager.requestWithStatusCode(
    endpoint: endpoint,
    responseType: PostResponse.self
) { result in
    
    switch result {
    case .success(let response):
        print(response)
    case .failure(let error):
        print(error)
    }
}

Raw Data Request

manager.requestData(
    endpoint: endpoint
) { result in
    
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        print(error)
    }
}

Empty Response Request

Useful for:

* DELETE operations
* Logout requests
* Endpoints returning HTTP 204

manager.requestEmpty(
    endpoint: endpoint
) { result in
    
    switch result {
    case .success:
        print("Success")
    case .failure(let error):
        print(error)
    }
}

SSL Pinning

Initialize NetworkManager with your certificate name:

let manager = NetworkManager(
    certificateName: "my_certificate"
)

Enable SSL Pinning:

manager.setSSLPinning(
    status: true
)

Disable SSL Pinning:

manager.setSSLPinning(
    status: false
)

Logger

Add Logs

await NetSecureLogger.shared.addLog(
    message: "Request started"
)

Get Logs

let logs = await NetSecureLogger.shared.getLogs()

Export Logs

let exportedLogs = await NetSecureLogger.shared.exportLogs()

Clear Logs

await NetSecureLogger.shared.clearLogs()

Endpoint Configuration

GET Request

let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/users",
    method: .get
)

POST Request

struct LoginRequest: Codable {
    let email: String
    let password: String
}
let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/login",
    method: .post,
    model: LoginRequest(
        email: "user@example.com",
        password: "password"
    )
)

Query Parameters

let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/users",
    method: .get,
    queryParameters: [
        "page": "1",
        "size": "10"
    ]
)

Custom Headers

let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/profile",
    method: .get,
    headers: [
        "Authorization": "Bearer token"
    ]
)

Requirements

* iOS 15.0+
* Swift 5.9+
* Xcode 15+

Roadmap

v1.3.0

* WebSocket Support
* Auto Reconnect
* AsyncStream Message Handling
* Ping/Pong Support

v1.4.0

* Multipart Upload
* File Download
* Progress Tracking

v2.0.0

* Interceptors
* Retry Policies
* Token Refresh Support
* Middleware System

Author

İlker Uğur Kaya

GitHub:
https://github.com/kayailkerugur/NetSecureKit

License

MIT License