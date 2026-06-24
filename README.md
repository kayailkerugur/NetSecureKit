# NetSecureKit

A lightweight, secure, and modern networking library for iOS, built with Swift.

NetSecureKit simplifies network communication without sacrificing security or clarity. It provides SSL Pinning, Async/Await support, response validation, raw data handling, and a built-in thread-safe logging system.

---

## Features

- SSL Pinning Support
- Async/Await & Completion Handler APIs
- HTTP Status Code Validation
- Raw Data & Empty Response Handling
- Thread-Safe Logging System
- Codable Request/Response Support
- Lightweight Architecture
- Swift Package Manager Support

---

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/kayailkerugur/NetSecureKit.git",
        from: "1.2.0"
    )
]
```

Or add it directly in Xcode:

1. **File → Add Package Dependencies**
2. Paste the URL:
```
https://github.com/kayailkerugur/NetSecureKit.git
```

---

## Quick Start

### Create an Endpoint

```swift
import NetSecureKit

let endpoint = EndpointModel(
    baseURL: "https://jsonplaceholder.typicode.com",
    path: "/posts/1",
    method: .get
)
```

### Define a Response Model

```swift
struct PostResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
```

---

## Making Requests

### Completion Handler

```swift
let manager = NetworkManager()
manager.request(endpoint: endpoint, responseType: PostResponse.self) { result in
    switch result {
    case .success(let response): print(response)
    case .failure(let error): print(error)
    }
}
```

### Async/Await

```swift
let result = await manager.requestAsync(endpoint: endpoint, responseType: PostResponse.self)
switch result {
case .success(let response): print(response)
case .failure(let error): print(error)
}
```

### HTTP Status Code Validation

```swift
manager.requestWithStatusCode(endpoint: endpoint, responseType: PostResponse.self) { result in
    switch result {
    case .success(let response): print(response)
    case .failure(let error): print(error)
    }
}
```

### Raw Data

```swift
manager.requestData(endpoint: endpoint) { result in
    switch result {
    case .success(let data): print(data)
    case .failure(let error): print(error)
    }
}
```

### Empty Response

Useful for DELETE operations, logout requests, or endpoints returning HTTP 204.

```swift
manager.requestEmpty(endpoint: endpoint) { result in
    switch result {
    case .success: print("Success")
    case .failure(let error): print(error)
    }
}
```

---

## SSL Pinning

```swift
// Initialize with your certificate
let manager = NetworkManager(certificateName: "my_certificate")

// Enable
manager.setSSLPinning(status: true)

// Disable
manager.setSSLPinning(status: false)
```

---

## Logging

```swift
// Add a log entry
await NetSecureLogger.shared.addLog(message: "Request started")

// Retrieve logs
let logs = await NetSecureLogger.shared.getLogs()

// Export logs
let exported = await NetSecureLogger.shared.exportLogs()

// Clear logs
await NetSecureLogger.shared.clearLogs()
```

---

## Endpoint Configuration

### GET Request

```swift
let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/users",
    method: .get
)
```

### POST Request

```swift
struct LoginRequest: Codable {
    let email: String
    let password: String
}

let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/login",
    method: .post,
    model: LoginRequest(email: "user@example.com", password: "password")
)
```

### Query Parameters

```swift
let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/users",
    method: .get,
    queryParameters: ["page": "1", "size": "10"]
)
```

### Custom Headers

```swift
let endpoint = EndpointModel(
    baseURL: "https://api.example.com",
    path: "/profile",
    method: .get,
    headers: ["Authorization": "Bearer token"]
)
```

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 15.0+ |
| Swift | 5.9+ |
| Xcode | 15+ |

---

## Roadmap

**v1.3.0**
- WebSocket Support
- Auto Reconnect
- AsyncStream Message Handling
- Ping/Pong Support

**v1.4.0**
- Multipart Upload
- File Download
- Progress Tracking

**v2.0.0**
- Interceptors & Retry Policies
- Token Refresh Support
- Middleware System

---

## Author

**İlker Uğur Kaya** · [github.com/kayailkerugur](https://github.com/kayailkerugur/NetSecureKit)

---

## License

MIT License