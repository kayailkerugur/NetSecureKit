//
//  NetworkManagerTests.swift
//  NetSecureKit
//
//  Created by Ilker Ugur Kaya on 23.06.2026.
//

import XCTest
@testable import NetSecureKit

final class NetworkManagerTests: XCTestCase {
    
    struct TestResponse: Decodable, Sendable {
        let userId: Int
        let id: Int
        let title: String
        let body: String
    }
    
    func testRequestSuccess() {
        let expectation = XCTestExpectation(description: "Request should succeed")
        
        let manager = NetworkManager()
        manager.setSSLPinning(status: false)
        
        let endpoint = EndpointModel(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/posts/1",
            method: .get
        )
        
        manager.request(
            endpoint: endpoint,
            responseType: TestResponse.self
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.id, 1)
                XCTAssertFalse(response.title.isEmpty)
                
            case .failure(let error):
                XCTFail("Request failed: \(error)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testRequestWithStatusCodeSuccess() {
        let expectation = XCTestExpectation(description: "Request with status code should succeed")
        
        let manager = NetworkManager()
        manager.setSSLPinning(status: false)
        
        let endpoint = EndpointModel(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/posts/1",
            method: .get
        )
        
        manager.requestWithStatusCode(
            endpoint: endpoint,
            responseType: TestResponse.self
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.id, 1)
                
            case .failure(let error):
                XCTFail("Request failed: \(error)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testRequestWithStatusCodeFailure404() {
        let expectation = XCTestExpectation(description: "Request should fail with 404")
        
        let manager = NetworkManager()
        manager.setSSLPinning(status: false)
        
        let endpoint = EndpointModel(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/wrong-url",
            method: .get
        )
        
        manager.requestWithStatusCode(
            endpoint: endpoint,
            responseType: TestResponse.self
        ) { result in
            switch result {
            case .success:
                XCTFail("Request should not succeed")
                
            case .failure:
                XCTAssertTrue(true)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testRequestAsyncSuccess() async {
        let manager = NetworkManager()
        manager.setSSLPinning(status: false)
        
        let endpoint = EndpointModel(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/posts/1",
            method: .get
        )
        
        let result = await manager.requestAsync(
            endpoint: endpoint,
            responseType: TestResponse.self
        )
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response.id, 1)
            XCTAssertFalse(response.title.isEmpty)
            
        case .failure(let error):
            XCTFail("Async request failed: \(error)")
        }
    }
    
    func testRequestDataSuccess() {
        let expectation = XCTestExpectation(description: "Request data should succeed")
        
        let manager = NetworkManager()
        manager.setSSLPinning(status: false)
        
        let endpoint = EndpointModel(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/posts/1",
            method: .get
        )
        
        manager.requestData(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                XCTAssertFalse(data.isEmpty)
                
            case .failure(let error):
                XCTFail("Data request failed: \(error)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testRequestEmptySuccess() {
        let expectation = XCTestExpectation(description: "Empty request should succeed")
        
        let manager = NetworkManager()
        manager.setSSLPinning(status: false)
        
        let endpoint = EndpointModel(
            baseURL: "https://jsonplaceholder.typicode.com",
            path: "/posts/1",
            method: .delete
        )
        
        manager.requestEmpty(endpoint: endpoint) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
                
            case .failure(let error):
                XCTFail("Empty request failed: \(error)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
}
