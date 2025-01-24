//
//  LogView.swift
//  NetSecureKitDemo
//
//  Created by İlker Kaya on 24.01.2025.
//

import SwiftUI
import NetSecureKit

struct LogView: View {
    let log: Logger.LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "doc.text")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text(log.timestamp)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(log.functionName)
                    .font(.headline)
                    .foregroundColor(.blue)

                Text(log.message)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
            }
            .padding(.vertical, 8)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
                           startPoint: .top,
                           endPoint: .bottom)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
