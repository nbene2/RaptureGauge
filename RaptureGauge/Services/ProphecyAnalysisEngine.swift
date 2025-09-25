import Foundation
import Combine

// MARK: - Analysis Models

struct ProphecyAnalysisResult: Codable {
    let relevanceScore: Float
    let confidence: Float
    let keyIndicators: [String]
    let prophecyAdvancement: Bool
    let temporalProximity: String
    let summary: String
}

struct NewsArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let content: String?
    let url: String
    let publishedAt: Date
    let source: String
}

// MARK: - Main Engine

class ProphecyAnalysisEngine: ObservableObject {
    static let shared = ProphecyAnalysisEngine()

    @Published var isAnalyzing = false
    @Published var lastAnalysisDate = Date()
    @Published var analysisCount = 0
    @Published var monthlyAPIUsage: (used: Int, limit: Int) = (0, 1000)

    private let openAIClient = OpenAIClient()
    private let newsClient = NewsAPIClient()
    private let earthquakeClient = USGSClient()
    private let cacheManager = AnalysisCacheManager()
    private let calculator = RaptureCalculator()

    private var cancellables = Set<AnyCancellable>()
    private var analysisTimer: Timer?

    init() {
        setupAutoRefresh()
    }

    private func setupAutoRefresh() {
        // Check every 4 hours
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 14400, repeats: true) { _ in
            Task {
                await self.performFullAnalysis()
            }
        }
    }

    // MARK: - Main Analysis

    func performFullAnalysis() async {
        await MainActor.run {
            self.isAnalyzing = true
        }

        do {
            // 1. Fetch latest news
            let newsArticles = try await fetchRelevantNews()
            print("Fetched \(newsArticles.count) relevant articles")

            // 2. Fetch earthquake data
            let earthquakes = try await earthquakeClient.fetchRecentEarthquakes()
            print("Fetched \(earthquakes.count) earthquakes")

            // 3. Analyze news against prophecies
            let analyses = try await analyzeNewsAgainstProphecies(newsArticles)

            // 4. Update condition scores based on analysis
            await updateConditionScores(from: analyses)

            // 5. Process earthquake data
            await processEarthquakeData(earthquakes)

            // 6. Recalculate main gauge
            await MainActor.run {
                self.calculator.calculateCurrentReadiness()
                self.lastAnalysisDate = Date()
                self.analysisCount += newsArticles.count
            }

            // 7. Check for critical alerts
            checkForCriticalAlerts()

        } catch {
            print("Analysis error: \(error)")
        }

        await MainActor.run {
            self.isAnalyzing = false
        }
    }

    // MARK: - News Fetching

    private func fetchRelevantNews() async throws -> [NewsArticle] {
        let keywords = [
            "Israel Jerusalem",
            "Temple Mount",
            "digital currency CBDC",
            "Russia Iran alliance",
            "Christian persecution",
            "earthquake",
            "red heifer",
            "Third Temple",
            "peace treaty Middle East",
            "cashless society"
        ]

        var allArticles: [NewsArticle] = []

        for keyword in keywords {
            let articles = try await newsClient.fetchNews(query: keyword)
            allArticles.append(contentsOf: articles)
        }

        // Filter and deduplicate
        let uniqueArticles = Array(Set(allArticles))
        return filterRelevantArticles(uniqueArticles)
    }

    private func filterRelevantArticles(_ articles: [NewsArticle]) -> [NewsArticle] {
        let prophecyKeywords = [
            "Israel", "Jerusalem", "Temple", "Iran", "Russia", "Turkey",
            "earthquake", "CBDC", "digital currency", "persecution", "Christian",
            "peace", "treaty", "covenant", "red heifer", "sacrifice"
        ]

        return articles.filter { article in
            // Must be less than 48 hours old
            guard article.publishedAt > Date().addingTimeInterval(-172800) else { return false }

            // Must contain at least 2 prophecy keywords
            let text = "\(article.title) \(article.description) \(article.content ?? "")"
            let matchCount = prophecyKeywords.filter { text.lowercased().contains($0.lowercased()) }.count
            return matchCount >= 2
        }
    }

    // MARK: - GPT-4 Analysis

    private func analyzeNewsAgainstProphecies(_ articles: [NewsArticle]) async throws -> [(article: NewsArticle, condition: RaptureCondition, result: ProphecyAnalysisResult)] {
        var results: [(NewsArticle, RaptureCondition, ProphecyAnalysisResult)] = []

        // Get all active conditions
        let conditions = ConditionData.shared.getAllConditions()

        // Batch articles for efficiency
        let articleBatches = articles.chunked(into: 5)

        for batch in articleBatches {
            for article in batch {
                // Check cache first
                if let cached = cacheManager.getCachedAnalysis(for: article.url) {
                    results.append(contentsOf: cached)
                    continue
                }

                // Analyze against relevant conditions
                let relevantConditions = conditions.filter { condition in
                    isArticleRelevantToCondition(article, condition)
                }

                for condition in relevantConditions {
                    if let result = try await openAIClient.analyzeArticle(article, against: condition) {
                        if result.relevanceScore > 0.7 {
                            results.append((article, condition, result))
                            cacheManager.cacheAnalysis(article: article, condition: condition, result: result)
                        }
                    }
                }
            }

            // Rate limiting
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second between batches
        }

        return results
    }

    private func isArticleRelevantToCondition(_ article: NewsArticle, _ condition: RaptureCondition) -> Bool {
        let text = "\(article.title) \(article.description)".lowercased()

        switch condition.category {
        case .israelJerusalem:
            return text.contains("israel") || text.contains("jerusalem") || text.contains("temple")
        case .technology:
            return text.contains("digital") || text.contains("cbdc") || text.contains("ai") || text.contains("surveillance")
        case .geopolitical:
            return text.contains("russia") || text.contains("iran") || text.contains("turkey") || text.contains("china")
        case .naturalDisasters:
            return text.contains("earthquake") || text.contains("disaster") || text.contains("famine")
        case .persecution:
            return text.contains("christian") || text.contains("persecution") || text.contains("church")
        default:
            return true // Check all others
        }
    }

    // MARK: - Score Updates

    private func updateConditionScores(from analyses: [(article: NewsArticle, condition: RaptureCondition, result: ProphecyAnalysisResult)]) async {
        var conditionUpdates: [UUID: Float] = [:]

        for (_, condition, result) in analyses {
            if result.prophecyAdvancement && result.confidence > 0.6 {
                let scoreIncrease = result.relevanceScore * result.confidence * 0.1
                conditionUpdates[condition.id] = (conditionUpdates[condition.id] ?? 0) + scoreIncrease
            }
        }

        // Create local copy for closure
        let updates = conditionUpdates

        // Apply updates to conditions
        await MainActor.run {
            for (conditionId, scoreIncrease) in updates {
                updateConditionScore(conditionId: conditionId, increase: scoreIncrease)
            }
        }
    }

    private func updateConditionScore(conditionId: UUID, increase: Float) {
        // This would update the actual condition in ConditionData
        // For now, just trigger recalculation
        calculator.calculateCurrentReadiness()
    }

    // MARK: - Earthquake Processing

    private func processEarthquakeData(_ earthquakes: [USGSClient.Earthquake]) async {
        let significantQuakes = earthquakes.filter { $0.magnitude >= 5.0 }
        let diverseLocations = Set(significantQuakes.map { $0.location }).count

        // Update earthquake condition based on frequency and diversity
        let earthquakeScore = Float(significantQuakes.count) / 100.0 * Float(diverseLocations) / 10.0

        await MainActor.run {
            // Update natural disasters condition
            // This would update the actual condition score
            print("Earthquake activity score: \(earthquakeScore)")
        }
    }

    // MARK: - Alerts

    private func checkForCriticalAlerts() {
        let currentScore = calculator.currentScore.percentage

        if currentScore > 90 {
            NotificationManager.shared.sendCriticalAlert(
                title: "Critical Convergence Level",
                body: "Rapture readiness has reached \(Int(currentScore))% - unprecedented convergence detected"
            )
        }
    }
}

// MARK: - Helper Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}