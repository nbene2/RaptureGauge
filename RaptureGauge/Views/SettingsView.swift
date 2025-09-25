import SwiftUI

struct SettingsView: View {
    @State private var openAIKey = ""
    @State private var newsAPIKey = ""
    @State private var claudeAPIKey = ""
    @State private var showingSaveAlert = false
    @State private var alertMessage = ""
    @StateObject private var analysisEngine = ProphecyAnalysisEngine.shared
    @State private var isAutoRefreshEnabled = true
    @State private var refreshInterval = 4 // hours

    var body: some View {
        NavigationView {
            Form {
                // API Keys Section
                Section(header: Text("API Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OpenAI API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SecureField("sk-...", text: $openAIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Link("Get API Key →", destination: URL(string: "https://platform.openai.com/api-keys")!)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("NewsAPI.org Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SecureField("Your NewsAPI key", text: $newsAPIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Link("Get Free API Key →", destination: URL(string: "https://newsapi.org/register")!)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Claude API Key (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SecureField("sk-ant-...", text: $claudeAPIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Link("Get API Key →", destination: URL(string: "https://console.anthropic.com/")!)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)

                    Button(action: saveAPIKeys) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("Save API Keys Securely")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                // Auto-Refresh Settings
                Section(header: Text("Automatic Updates")) {
                    Toggle("Auto-Refresh News", isOn: $isAutoRefreshEnabled)

                    if isAutoRefreshEnabled {
                        Picker("Refresh Interval", selection: $refreshInterval) {
                            Text("Every 2 hours").tag(2)
                            Text("Every 4 hours").tag(4)
                            Text("Every 6 hours").tag(6)
                            Text("Every 12 hours").tag(12)
                            Text("Once daily").tag(24)
                        }

                        Button("Refresh Now") {
                            Task {
                                await analysisEngine.performFullAnalysis()
                            }
                        }
                        .disabled(analysisEngine.isAnalyzing)
                    }
                }

                // API Usage Section
                Section(header: Text("API Usage This Month")) {
                    UsageRow(
                        title: "OpenAI Tokens",
                        usage: APIUsageTracker.shared.getMonthlyUsage().openAITokens,
                        limit: 100000,
                        unit: "tokens"
                    )

                    UsageRow(
                        title: "NewsAPI Calls",
                        usage: APIUsageTracker.shared.getMonthlyUsage().newsAPICalls,
                        limit: 100,
                        unit: "calls"
                    )

                    HStack {
                        Text("Estimated Cost")
                        Spacer()
                        Text("$\(String(format: "%.2f", APIUsageTracker.shared.getMonthlyUsage().estimatedCost))")
                            .foregroundColor(.orange)
                    }

                    Button("Reset Usage Counter") {
                        APIUsageTracker.shared.resetUsage()
                    }
                    .foregroundColor(.red)
                }

                // Cache Management
                Section(header: Text("Cache Management")) {
                    let cacheStats = AnalysisCacheManager().getCacheStatistics()

                    HStack {
                        Text("Cached Entries")
                        Spacer()
                        Text("\(cacheStats.totalEntries)")
                    }

                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text("\(String(format: "%.1f", cacheStats.sizeInMB)) MB")
                    }

                    if let oldestDate = cacheStats.oldestEntry {
                        HStack {
                            Text("Oldest Entry")
                            Spacer()
                            Text(oldestDate, style: .date)
                                .font(.caption)
                        }
                    }

                    Button("Clear Cache") {
                        AnalysisCacheManager().clearCache()
                    }
                    .foregroundColor(.red)
                }

                // Analysis Status
                Section(header: Text("Analysis Status")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        if analysisEngine.isAnalyzing {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Analyzing...")
                                    .foregroundColor(.orange)
                            }
                        } else {
                            Text("Idle")
                                .foregroundColor(.green)
                        }
                    }

                    HStack {
                        Text("Last Analysis")
                        Spacer()
                        Text(analysisEngine.lastAnalysisDate, style: .relative)
                            .font(.caption)
                    }

                    HStack {
                        Text("Articles Analyzed")
                        Spacer()
                        Text("\(analysisEngine.analysisCount)")
                    }
                }

                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link("API Documentation", destination: URL(string: "https://github.com/yourusername/rapture-gauge")!)

                    Button("Test Notification") {
                        NotificationManager.shared.sendCriticalAlert(
                            title: "Test Alert",
                            body: "This is a test notification from Rapture Gauge"
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadAPIKeys()
            }
            .alert("API Keys", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func loadAPIKeys() {
        // Load existing keys (show masked)
        if KeychainManager.shared.retrieve(for: .openAIKey) != nil {
            openAIKey = "••••••••••••••••"
        }
        if KeychainManager.shared.retrieve(for: .newsAPIKey) != nil {
            newsAPIKey = "••••••••••••••••"
        }
        if KeychainManager.shared.retrieve(for: .claudeAPIKey) != nil {
            claudeAPIKey = "••••••••••••••••"
        }
    }

    private func saveAPIKeys() {
        var saved = 0
        var failed = 0

        // Only save if not masked placeholder
        if !openAIKey.isEmpty && !openAIKey.contains("•") {
            if KeychainManager.shared.save(key: openAIKey, for: .openAIKey) {
                saved += 1
            } else {
                failed += 1
            }
        }

        if !newsAPIKey.isEmpty && !newsAPIKey.contains("•") {
            if KeychainManager.shared.save(key: newsAPIKey, for: .newsAPIKey) {
                saved += 1
            } else {
                failed += 1
            }
        }

        if !claudeAPIKey.isEmpty && !claudeAPIKey.contains("•") {
            if KeychainManager.shared.save(key: claudeAPIKey, for: .claudeAPIKey) {
                saved += 1
            } else {
                failed += 1
            }
        }

        if failed > 0 {
            alertMessage = "Failed to save \(failed) key(s). Please try again."
        } else if saved > 0 {
            alertMessage = "Successfully saved \(saved) API key(s) to secure keychain!"
        } else {
            alertMessage = "No new keys to save."
        }

        showingSaveAlert = true
        loadAPIKeys() // Reload to show masked keys
    }
}

struct UsageRow: View {
    let title: String
    let usage: Int
    let limit: Int
    let unit: String

    var usagePercentage: Double {
        Double(usage) / Double(limit)
    }

    var usageColor: Color {
        if usagePercentage > 0.9 { return .red }
        if usagePercentage > 0.7 { return .orange }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(usage)/\(limit) \(unit)")
                    .font(.caption)
                    .foregroundColor(usageColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    Rectangle()
                        .fill(usageColor)
                        .frame(width: geometry.size.width * min(usagePercentage, 1.0), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 2)
    }
}