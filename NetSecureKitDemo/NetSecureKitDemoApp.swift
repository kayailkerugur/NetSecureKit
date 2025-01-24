//
//  NetSecureKitDemoApp.swift
//  NetSecureKitDemo
//
//  Created by İlker Kaya on 22.01.2025.
//

import SwiftUI
import NetSecureKit

@main
struct NetSecureKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Logger.shared.log(message: "Uygulama başlatıldı.")
                }
        }
    }
}
