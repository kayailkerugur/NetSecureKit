//
//  LogListView.swift
//  NetSecureKitDemo
//
//  Created by İlker Kaya on 24.01.2025.
//

import SwiftUI
import NetSecureKit

struct LogListView: View {
    @State private var logs: [Logger.LogEntry] = []

    var body: some View {
        VStack {
            if logs.isEmpty {
                Text("Henüz log yok.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(logs.indices, id: \.self) { index in
                            LogView(log: logs[index])
                                .padding(.horizontal)
                        }
                    }
                }
            }
            Button(action: fetchLogs) {
                Text("Logları Yenile")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationTitle("Log Listesi")
        .onAppear(perform: fetchLogs)
    }

    private func fetchLogs() {
        logs = Logger.shared.getLogs()
    }
}

#Preview {
    LogListView()
}
