import SwiftUI

struct RaptureClockGauge: View {
    let reading: String
    let percentage: Float
    @State private var animatedPercentage: Float = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(animatedPercentage / 100))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: gaugeColors),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: animatedPercentage)

                // Clock face markings
                ForEach(0..<12) { hour in
                    Rectangle()
                        .fill(Color.primary.opacity(0.5))
                        .frame(width: 2, height: hour % 3 == 0 ? 15 : 10)
                        .offset(y: -geometry.size.width / 2 + 35)
                        .rotationEffect(.degrees(Double(hour) * 30))
                }

                // Clock hands
                ClockHands(time: reading, size: geometry.size.width)

                // Center display
                VStack(spacing: 8) {
                    Text(reading)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)

                    Text("\(Int(percentage))% READY")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    // Urgency indicator
                    if percentage > 85 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            Text("CRITICAL")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            .padding(20)
        }
        .onAppear {
            withAnimation {
                animatedPercentage = percentage
            }
        }
        .onChange(of: percentage) { _, newValue in
            withAnimation {
                animatedPercentage = newValue
            }
        }
    }

    var gaugeColors: [Color] {
        [
            Color.green,
            Color.green,
            Color.yellow,
            Color.orange,
            Color.red,
            Color.red.opacity(0.8)
        ]
    }
}

struct ClockHands: View {
    let time: String
    let size: CGFloat

    var hourAngle: Double {
        let components = time.split(separator: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minuteComponent = components[1].split(separator: " ").first,
              let minute = Int(minuteComponent) else { return 0 }

        let isPM = time.contains("PM")
        var adjustedHour = hour
        if isPM && hour != 12 {
            adjustedHour += 12
        } else if !isPM && hour == 12 {
            adjustedHour = 0
        }

        let hourDegrees = (Double(adjustedHour % 12) * 30) + (Double(minute) * 0.5)
        return hourDegrees - 90
    }

    var minuteAngle: Double {
        let components = time.split(separator: ":")
        guard components.count >= 2,
              let minuteComponent = components[1].split(separator: " ").first,
              let minute = Int(minuteComponent) else { return 0 }

        return (Double(minute) * 6) - 90
    }

    var body: some View {
        ZStack {
            // Hour hand
            Rectangle()
                .fill(Color.primary)
                .frame(width: 4, height: size * 0.25)
                .offset(y: -size * 0.125)
                .rotationEffect(.degrees(hourAngle))

            // Minute hand
            Rectangle()
                .fill(Color.primary)
                .frame(width: 2, height: size * 0.35)
                .offset(y: -size * 0.175)
                .rotationEffect(.degrees(minuteAngle))

            // Center dot
            Circle()
                .fill(Color.primary)
                .frame(width: 10, height: 10)
        }
    }
}

struct TrendIndicator: View {
    let trend: ReadinessScore.Trend
    let acceleration: Float

    var body: some View {
        HStack(spacing: 12) {
            // Trend arrow
            Text(trend.rawValue)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(trendColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("Trend: \(trendText)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Text("\(acceleration > 0 ? "+" : "")\(String(format: "%.1f", acceleration))% this year")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }

    var trendColor: Color {
        switch trend {
        case .rising: return .red
        case .falling: return .green
        case .stable: return .orange
        }
    }

    var trendText: String {
        switch trend {
        case .rising: return "Rising"
        case .falling: return "Falling"
        case .stable: return "Stable"
        }
    }
}