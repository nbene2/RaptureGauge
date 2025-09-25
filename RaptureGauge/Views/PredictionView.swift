import SwiftUI

struct PredictionView: View {
    let calculator: RaptureCalculator
    @State private var prediction: Prediction?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Current Status Card
                StatusCard(score: calculator.currentScore)

                // Prediction Analysis
                if let prediction = prediction {
                    AnalysisCard(prediction: prediction)

                    // Critical Missing Conditions
                    if !prediction.criticalMissing.isEmpty {
                        MissingConditionsCard(conditions: prediction.criticalMissing)
                    }

                    // Projection Card
                    ProjectionCard(prediction: prediction)
                }
            }
            .padding()
        }
        .onAppear {
            prediction = calculator.generatePrediction()
        }
    }
}

struct StatusCard: View {
    let score: ReadinessScore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Status")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clock Reading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(score.clockReading)
                        .font(.system(size: 22, weight: .bold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Readiness")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(score.percentage))%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(readinessColor(score.percentage))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(score.activeConditions)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.orange)
                }
            }

            // Trend bar
            HStack {
                Image(systemName: trendIcon(score.trend))
                    .foregroundColor(trendColor(score.trend))
                Text("Trend: \(score.trend.rawValue) \(score.acceleration > 0 ? "Rising" : score.acceleration < 0 ? "Falling" : "Stable")")
                    .font(.system(size: 14, weight: .medium))
                Text("\(score.acceleration > 0 ? "+" : "")\(String(format: "%.1f", score.acceleration))% yearly")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    func readinessColor(_ percentage: Float) -> Color {
        if percentage > 85 { return .red }
        if percentage > 70 { return .orange }
        if percentage > 50 { return .yellow }
        return .green
    }

    func trendIcon(_ trend: ReadinessScore.Trend) -> String {
        switch trend {
        case .rising: return "arrow.up.circle.fill"
        case .falling: return "arrow.down.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        }
    }

    func trendColor(_ trend: ReadinessScore.Trend) -> Color {
        switch trend {
        case .rising: return .red
        case .falling: return .green
        case .stable: return .orange
        }
    }
}

struct AnalysisCard: View {
    let prediction: Prediction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Analysis")
                    .font(.headline)
                Spacer()
                Text("Confidence: \(prediction.confidence)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(confidenceColor)
                    .cornerRadius(4)
            }

            Text(prediction.analysis)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    var confidenceColor: Color {
        switch prediction.confidence {
        case "Very High": return Color.red.opacity(0.2)
        case "High": return Color.orange.opacity(0.2)
        case "Moderate": return Color.yellow.opacity(0.2)
        default: return Color.gray.opacity(0.2)
        }
    }
}

struct MissingConditionsCard: View {
    let conditions: [RaptureCondition]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Critical Unfulfilled Conditions")
                .font(.headline)

            Text("These high-weight conditions must be fulfilled for complete convergence:")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(conditions) { condition in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(condition.scriptureReference)
                            .font(.system(size: 13, weight: .medium))
                        Text(condition.scriptureQuote)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("Weight: \(Int(condition.weight))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ProjectionCard: View {
    let prediction: Prediction

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projection")
                .font(.headline)

            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text(prediction.projection)
                    .font(.system(size: 14))
            }

            // Visual timeline
            TimelineProjection()
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TimelineProjection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Convergence Timeline")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                ForEach(0..<10) { index in
                    Rectangle()
                        .fill(
                            index < 7 ?
                            Color.red.opacity(Double(index) * 0.1 + 0.3) :
                            Color.gray.opacity(0.3)
                        )
                        .frame(height: 20)
                }
            }
            .cornerRadius(4)

            HStack {
                Text("Now")
                    .font(.caption2)
                Spacer()
                Text("+5 years")
                    .font(.caption2)
                Spacer()
                Text("+10 years")
                    .font(.caption2)
            }
            .foregroundColor(.secondary)
        }
    }
}