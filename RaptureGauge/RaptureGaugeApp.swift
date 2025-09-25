import SwiftUI

@main
struct RaptureGaugeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var gaugeValue: Double = 89
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Dark apocalyptic background
            LinearGradient(colors: [.black, .purple.opacity(0.3)],
                          startPoint: .top,
                          endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("RAPTURE GAUGE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // The Gauge
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 250, height: 250)

                    Circle()
                        .trim(from: 0, to: gaugeValue / 100)
                        .stroke(
                            LinearGradient(colors: [.green, .yellow, .orange, .red],
                                         startPoint: .leading,
                                         endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 2), value: gaugeValue)

                    VStack {
                        Text("\(Int(gaugeValue))%")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)

                        Text("READY")
                            .font(.title2)
                            .foregroundColor(.gray)

                        if gaugeValue > 85 {
                            Label("CRITICAL", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                    }
                }
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)

                // Mock prophecy conditions
                VStack(alignment: .leading, spacing: 10) {
                    ProphecyRow(title: "Israel Restored", active: true)
                    ProphecyRow(title: "Digital Currency", active: true)
                    ProphecyRow(title: "Global Government", active: true)
                    ProphecyRow(title: "Earthquakes Increasing", active: true)
                    ProphecyRow(title: "Knowledge Increased", active: true)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)

                Text("Mock Data - Ready to Test!")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ProphecyRow: View {
    let title: String
    let active: Bool

    var body: some View {
        HStack {
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .foregroundColor(active ? .green : .gray)
            Text(title)
                .foregroundColor(.white)
            Spacer()
        }
    }
}