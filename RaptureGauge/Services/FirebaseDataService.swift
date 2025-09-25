import Foundation
import Combine

// Simple Firebase data service - no API keys needed!
class FirebaseDataService: ObservableObject {
    static let shared = FirebaseDataService()

    // The backend URL (can be Firebase Functions or any backend)
    private let baseURL = "https://us-central1-rapture-gauge.cloudfunctions.net"
    // For testing: "http://localhost:5001/rapture-gauge/us-central1"

    @Published var currentGaugeData: GaugeData?
    @Published var isLoading = false
    @Published var lastError: String?
    @Published var lastUpdated: Date?

    private var refreshTimer: Timer?

    struct GaugeData: Codable {
        let gaugePercentage: Float
        let clockReading: String
        let baseScore: Float
        let newsScore: Float
        let earthquakeScore: Float
        let activeConditions: Int
        let criticalNews: [NewsItem]
        let majorEarthquakes: [Earthquake]
        let trend: String
        let articlesAnalyzed: Int
        let earthquakesTracked: Int

        struct NewsItem: Codable {
            let articleIndex: Int
            let score: Float
            let category: String
            let summary: String
        }

        struct Earthquake: Codable {
            let magnitude: Float
            let location: String
            let time: String
        }
    }

    init() {
        // Fetch data immediately
        fetchGaugeData()

        // Refresh every 30 minutes (backend updates every 12 hours)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { _ in
            self.fetchGaugeData()
        }
    }

    func fetchGaugeData() {
        isLoading = true
        lastError = nil

        guard let url = URL(string: "\(baseURL)/getGaugeData") else {
            lastError = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.lastError = error.localizedDescription
                    // Use cached data if available
                    self?.loadCachedData()
                    return
                }

                guard let data = data else {
                    self?.lastError = "No data received"
                    self?.loadCachedData()
                    return
                }

                do {
                    let gaugeData = try JSONDecoder().decode(GaugeData.self, from: data)
                    self?.currentGaugeData = gaugeData
                    self?.lastUpdated = Date()
                    self?.cacheData(gaugeData)

                    // Update the calculator with new data
                    self?.updateCalculator(with: gaugeData)

                } catch {
                    self?.lastError = "Decoding error: \(error)"
                    self?.loadCachedData()
                }
            }
        }.resume()
    }

    private func updateCalculator(with data: GaugeData) {
        // Update the RaptureCalculator with backend data
        let calculator = RaptureCalculator()

        // Create a new ReadinessScore from backend data
        let score = ReadinessScore(
            percentage: data.gaugePercentage,
            clockReading: data.clockReading,
            trend: trendFromString(data.trend),
            acceleration: data.trend == "rising" ? 2.5 : 0,
            activeConditions: data.activeConditions,
            criticalMissing: []
        )

        calculator.currentScore = score
    }

    private func trendFromString(_ trend: String) -> ReadinessScore.Trend {
        switch trend {
        case "rising": return .rising
        case "falling": return .falling
        default: return .stable
        }
    }

    // MARK: - Caching for offline use

    private func cacheData(_ data: GaugeData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "cached_gauge_data")
            UserDefaults.standard.set(Date(), forKey: "cached_gauge_date")
        }
    }

    private func loadCachedData() {
        if let cached = UserDefaults.standard.data(forKey: "cached_gauge_data"),
           let data = try? JSONDecoder().decode(GaugeData.self, from: cached) {
            self.currentGaugeData = data

            if let cacheDate = UserDefaults.standard.object(forKey: "cached_gauge_date") as? Date {
                self.lastUpdated = cacheDate
            }
        }
    }

    // MARK: - Manual refresh

    func refreshData() {
        fetchGaugeData()
    }

    // MARK: - Mock data for testing without backend

    func useMockData() {
        currentGaugeData = GaugeData(
            gaugePercentage: 89,
            clockReading: "11:52 PM",
            baseScore: 45,
            newsScore: 34,
            earthquakeScore: 10,
            activeConditions: 22,
            criticalNews: [
                GaugeData.NewsItem(
                    articleIndex: 1,
                    score: 0.85,
                    category: "Israel",
                    summary: "Temple Mount tensions escalate"
                ),
                GaugeData.NewsItem(
                    articleIndex: 2,
                    score: 0.75,
                    category: "Technology",
                    summary: "CBDC pilot launches in major economy"
                )
            ],
            majorEarthquakes: [
                GaugeData.Earthquake(
                    magnitude: 6.5,
                    location: "Turkey",
                    time: "2024-09-24"
                )
            ],
            trend: "rising",
            articlesAnalyzed: 45,
            earthquakesTracked: 8
        )
        lastUpdated = Date()
    }
}