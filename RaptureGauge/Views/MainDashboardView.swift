import SwiftUI

struct MainDashboardView: View {
    @StateObject private var calculator = RaptureCalculator()
    @StateObject private var firebaseService = FirebaseDataService.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Gauge Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Main Clock Gauge
                        RaptureClockGauge(
                            reading: calculator.currentScore.clockReading,
                            percentage: calculator.currentScore.percentage
                        )
                        .frame(height: 300)
                        .padding()

                        // Trend Indicator
                        TrendIndicator(
                            trend: calculator.currentScore.trend,
                            acceleration: calculator.currentScore.acceleration
                        )
                        .padding(.horizontal)

                        // Critical Active Conditions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Critical Active Conditions")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(calculator.getCriticalActiveConditions()) { condition in
                                ConditionRow(condition: condition)
                            }
                        }
                        .padding(.vertical)

                        // Window Info
                        WindowInfoCard(calculator: calculator)
                            .padding()
                    }
                }
                .navigationTitle("Rapture Readiness")
                .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Gauge", systemImage: "gauge.high")
            }
            .tag(0)

            // Categories Tab
            NavigationView {
                CategoryListView(calculator: calculator)
                    .navigationTitle("Categories")
            }
            .tabItem {
                Label("Categories", systemImage: "list.bullet")
            }
            .tag(1)

            // Prediction Tab
            NavigationView {
                PredictionView(calculator: calculator)
                    .navigationTitle("Analysis")
            }
            .tabItem {
                Label("Analysis", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(2)

            // History Tab
            NavigationView {
                HistoryView(calculator: calculator)
                    .navigationTitle("History")
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(3)

            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(4)
        }
        .onAppear {
            // Use Firebase data if available, otherwise calculate locally
            if let gaugeData = firebaseService.currentGaugeData {
                updateFromFirebase(gaugeData)
            } else {
                calculator.calculateCurrentReadiness()
                // Use mock data for testing
                firebaseService.useMockData()
            }
        }
    }

    private func updateFromFirebase(_ data: FirebaseDataService.GaugeData) {
        calculator.currentScore = ReadinessScore(
            percentage: data.gaugePercentage,
            clockReading: data.clockReading,
            trend: data.trend == "rising" ? .rising : data.trend == "falling" ? .falling : .stable,
            acceleration: data.trend == "rising" ? 2.5 : 0,
            activeConditions: data.activeConditions,
            criticalMissing: []
        )
    }
}

struct ConditionRow: View {
    let condition: RaptureCondition

    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(condition.scriptureReference)
                    .font(.system(size: 14, weight: .semibold))
                Text(condition.scriptureQuote)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Weight: \(Int(condition.weight))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text("\(Int(condition.confidenceScore * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(statusColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    var statusColor: Color {
        switch condition.currentStatus {
        case .fulfilled:
            return .green
        case .active:
            return .orange
        case .emerging:
            return .yellow
        case .notMet, .expired:
            return .gray
        }
    }
}

struct WindowInfoCard: View {
    let calculator: RaptureCalculator

    var body: some View {
        VStack(spacing: 12) {
            Text("100-Year Rolling Window")
                .font(.headline)

            HStack {
                VStack(alignment: .leading) {
                    Text("Window Start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(windowStartYear)
                        .font(.system(size: 18, weight: .semibold))
                }

                Spacer()

                VStack(alignment: .center) {
                    Text("Active Conditions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(calculator.currentScore.activeConditions)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Window End")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(windowEndYear)
                        .font(.system(size: 18, weight: .semibold))
                }
            }

            // Window progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(calculator.currentScore.percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    var windowStartYear: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date()) - 100
        return String(year)
    }

    var windowEndYear: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        return String(year)
    }
}