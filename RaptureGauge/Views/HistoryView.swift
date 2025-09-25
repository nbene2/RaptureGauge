import SwiftUI
import Charts

struct HistoryView: View {
    let calculator: RaptureCalculator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Historical Chart
                HistoricalChart(scores: calculator.historicalScores)
                    .frame(height: 250)
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(12)

                // Milestone Events
                MilestonesList()

                // Acceleration Analysis
                AccelerationCard(calculator: calculator)
            }
            .padding()
        }
    }
}

struct HistoricalChart: View {
    let scores: [(year: Int, score: Float)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("100-Year Window Progression")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart(scores, id: \.year) { item in
                    LineMark(
                        x: .value("Year", item.year),
                        y: .value("Score", item.score)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Year", item.year),
                        y: .value("Score", item.score)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color.red.opacity(0.1), Color.red.opacity(0.3)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartYScale(domain: 0...100)
            } else {
                // Fallback for iOS 15
                SimplifiedChart(scores: scores)
            }

            HStack {
                Label("Readiness %", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Current: \(Int(scores.last?.score ?? 0))%")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct SimplifiedChart: View {
    let scores: [(year: Int, score: Float)]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines
                ForEach(0..<5) { index in
                    Path { path in
                        let y = geometry.size.height * CGFloat(index) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                }

                // Line chart
                Path { path in
                    guard !scores.isEmpty else { return }

                    let xScale = geometry.size.width / CGFloat(scores.count - 1)
                    let yScale = geometry.size.height / 100

                    for (index, item) in scores.enumerated() {
                        let x = CGFloat(index) * xScale
                        let y = geometry.size.height - (CGFloat(item.score) * yScale)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [.green, .yellow, .orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
            }
        }
    }
}

struct MilestonesList: View {
    let milestones = [
        (year: 1948, event: "Israel Reborn", impact: "+15%"),
        (year: 1967, event: "Jerusalem Reunified", impact: "+12%"),
        (year: 1991, event: "Internet Era Begins", impact: "+8%"),
        (year: 2000, event: "Knowledge Explosion", impact: "+10%"),
        (year: 2020, event: "Global Pandemic", impact: "+5%"),
        (year: 2022, event: "Red Heifers Arrive", impact: "+3%")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Milestones")
                .font(.headline)

            ForEach(milestones, id: \.year) { milestone in
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)

                    Text(String(milestone.year))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .frame(width: 50, alignment: .leading)

                    Text(milestone.event)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(milestone.impact)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
}

struct AccelerationCard: View {
    let calculator: RaptureCalculator

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acceleration Analysis")
                .font(.headline)

            VStack(spacing: 16) {
                AccelerationRow(
                    period: "Last 50 years",
                    change: "+45%",
                    rate: "0.9% per year",
                    color: .orange
                )

                AccelerationRow(
                    period: "Last 20 years",
                    change: "+28%",
                    rate: "1.4% per year",
                    color: .red
                )

                AccelerationRow(
                    period: "Last 5 years",
                    change: "+12%",
                    rate: "2.4% per year",
                    color: .red
                )
            }

            Divider()

            Text("Convergence is accelerating exponentially. At current rate, critical mass will be reached within 5-15 years.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
}

struct AccelerationRow: View {
    let period: String
    let change: String
    let rate: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(period)
                    .font(.system(size: 13, weight: .medium))
                Text(rate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(change)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
    }
}