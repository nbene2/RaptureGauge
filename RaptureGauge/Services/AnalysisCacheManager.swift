import Foundation

class AnalysisCacheManager {
    private let cacheDirectory: URL
    private let cacheExpirationDays = 30
    private let nonMatchCacheDays = 7

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.cacheDirectory = documentsPath.appendingPathComponent("ProphecyAnalysisCache")

        // Create cache directory if it doesn't exist
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Clean old cache on init
        cleanExpiredCache()
    }

    struct CacheEntry: Codable {
        let articleURL: String
        let conditionID: UUID
        let analysisResult: ProphecyAnalysisResult
        let timestamp: Date
    }

    func cacheAnalysis(article: NewsArticle, condition: RaptureCondition, result: ProphecyAnalysisResult) {
        let entry = CacheEntry(
            articleURL: article.url,
            conditionID: condition.id,
            analysisResult: result,
            timestamp: Date()
        )

        let cacheKey = generateCacheKey(articleURL: article.url, conditionID: condition.id)
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).json")

        if let data = try? JSONEncoder().encode(entry) {
            try? data.write(to: fileURL)
        }
    }

    func getCachedAnalysis(for articleURL: String) -> [(NewsArticle, RaptureCondition, ProphecyAnalysisResult)]? {
        var results: [(NewsArticle, RaptureCondition, ProphecyAnalysisResult)] = []

        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)

            for fileURL in files {
                if fileURL.pathExtension == "json" {
                    if let data = try? Data(contentsOf: fileURL),
                       let entry = try? JSONDecoder().decode(CacheEntry.self, from: data) {
                        if entry.articleURL == articleURL {
                            // Check if cache is still valid
                            let age = Date().timeIntervalSince(entry.timestamp)
                            let maxAge = TimeInterval(cacheExpirationDays * 24 * 60 * 60)

                            if age < maxAge {
                                // We'd need to reconstruct the article and condition
                                // For now, returning nil for simplicity
                                return nil
                            }
                        }
                    }
                }
            }
        } catch {
            print("Cache read error: \(error)")
        }

        return results.isEmpty ? nil : results
    }

    func cleanExpiredCache() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey])

            for fileURL in files {
                if let attributes = try? fileURL.resourceValues(forKeys: [.creationDateKey]),
                   let creationDate = attributes.creationDate {
                    let age = Date().timeIntervalSince(creationDate)
                    let maxAge = TimeInterval(cacheExpirationDays * 24 * 60 * 60)

                    if age > maxAge {
                        try? FileManager.default.removeItem(at: fileURL)
                    }
                }
            }
        } catch {
            print("Cache cleanup error: \(error)")
        }
    }

    func getCacheStatistics() -> (totalEntries: Int, sizeInMB: Double, oldestEntry: Date?) {
        var totalSize: Int64 = 0
        var oldestDate: Date?
        var entryCount = 0

        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])

            for fileURL in files {
                if let attributes = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .creationDateKey]) {
                    if let size = attributes.fileSize {
                        totalSize += Int64(size)
                    }
                    if let date = attributes.creationDate {
                        if oldestDate == nil || date < oldestDate! {
                            oldestDate = date
                        }
                    }
                    entryCount += 1
                }
            }
        } catch {
            print("Cache statistics error: \(error)")
        }

        let sizeInMB = Double(totalSize) / (1024 * 1024)
        return (entryCount, sizeInMB, oldestDate)
    }

    func clearCache() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for fileURL in files {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Cache clear error: \(error)")
        }
    }

    private func generateCacheKey(articleURL: String, conditionID: UUID) -> String {
        let combined = "\(articleURL)_\(conditionID.uuidString)"
        return combined.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
    }
}

// MARK: - Usage Tracking

class APIUsageTracker {
    static let shared = APIUsageTracker()
    private let defaults = UserDefaults.standard

    private let openAITokensKey = "openai_tokens_used"
    private let newsAPICallsKey = "newsapi_calls"
    private let monthResetKey = "usage_month_reset"

    func recordOpenAIUsage(tokens: Int) {
        let currentTokens = defaults.integer(forKey: openAITokensKey)
        defaults.set(currentTokens + tokens, forKey: openAITokensKey)
        checkMonthlyReset()
    }

    func recordNewsAPICall() {
        let currentCalls = defaults.integer(forKey: newsAPICallsKey)
        defaults.set(currentCalls + 1, forKey: newsAPICallsKey)
        checkMonthlyReset()
    }

    func getMonthlyUsage() -> (openAITokens: Int, newsAPICalls: Int, estimatedCost: Double) {
        checkMonthlyReset()
        let tokens = defaults.integer(forKey: openAITokensKey)
        let calls = defaults.integer(forKey: newsAPICallsKey)

        // GPT-4 pricing: ~$0.01 per 1000 tokens
        let estimatedCost = Double(tokens) / 1000.0 * 0.01

        return (tokens, calls, estimatedCost)
    }

    private func checkMonthlyReset() {
        let lastReset = defaults.object(forKey: monthResetKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current

        if !calendar.isDate(lastReset, equalTo: Date(), toGranularity: .month) {
            // Reset counters for new month
            defaults.set(0, forKey: openAITokensKey)
            defaults.set(0, forKey: newsAPICallsKey)
            defaults.set(Date(), forKey: monthResetKey)
        }
    }

    func resetUsage() {
        defaults.set(0, forKey: openAITokensKey)
        defaults.set(0, forKey: newsAPICallsKey)
        defaults.set(Date(), forKey: monthResetKey)
    }
}