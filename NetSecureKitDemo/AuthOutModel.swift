//
//  AuthOutModel.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 24.01.2025.
//

import Foundation

public struct AuthOutModel: Codable {
    let isSuccessful: Bool
    let referenceId: String
    let user: User
    let token: String
    let expires: String
    let validity: String
    
    enum CodingKeys: String, CodingKey {
        case isSuccessful = "IsSuccessful"
        case referenceId = "ReferenceId"
        case user = "User"
        case token = "Token"
        case expires = "Expires"
        case validity = "Validity"
    }
}

struct User: Codable {
    let userId: Int
    let userName: String
    let userRole: String
    let userPartyId: Int
    let userPartyType: String
    let domainId: Int
    let domainCode: String
    let domainName: String
    let domainType: String
    let domainRole: String
    let domainPartyId: Int
    let domainPartyType: String
    let name: String
    let firstName: String
    let lastName: String?
    let profile: Profile?
    let staffId: Int?
    let staffCode: String?
    let history: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "UserId"
        case userName = "UserName"
        case userRole = "UserRole"
        case userPartyId = "UserPartyId"
        case userPartyType = "UserPartyType"
        case domainId = "DomainId"
        case domainCode = "DomainCode"
        case domainName = "DomainName"
        case domainType = "DomainType"
        case domainRole = "DomainRole"
        case domainPartyId = "DomainPartyId"
        case domainPartyType = "DomainPartyType"
        case name = "Name"
        case firstName = "FirstName"
        case lastName = "LastName"
        case profile = "Profile"
        case staffId = "StaffId"
        case staffCode = "StaffCode"
        case history = "History"
    }
}

struct Profile: Codable {
    let locale: String
    let image: String?
    let securityImage: String?
    
    enum CodingKeys: String, CodingKey {
        case locale = "Locale"
        case image = "Image"
        case securityImage = "SecurityImage"
    }
}
