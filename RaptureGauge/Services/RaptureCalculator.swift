import Foundation

class RaptureCalculator: ObservableObject {
    @Published var currentScore: ReadinessScore
    @Published var historicalScores: [(year: Int, score: Float)] = []

    private let conditions: [RaptureCondition]

    init() {
        self.conditions = ConditionData.shared.getAllConditions()
        self.currentScore = ReadinessScore(
            percentage: 0,
            clockReading: "12:00 AM",
            trend: .stable,
            acceleration: 0,
            activeConditions: 0,
            criticalMissing: []
        )
        calculateCurrentReadiness()
        calculateHistoricalData()
    }

    func calculateCurrentReadiness() {
        let score = calculateReadiness(for: Date())
        DispatchQueue.main.async {
            self.currentScore = score
        }
    }

    func calculateReadiness(for date: Date) -> ReadinessScore {
        let calendar = Calendar.current
        let windowStart = calendar.date(byAdding: .year, value: -100, to: date)!

        var totalScore: Float = 0
        var maxPossibleScore: Float = 0
        var activeCount = 0
        var criticalMissing: [String] = []

        for condition in conditions {
            maxPossibleScore += condition.weight

            // Check if condition is active in the 100-year window
            if let fulfillmentDate = condition.fulfillmentDate {
                if fulfillmentDate >= windowStart && fulfillmentDate <= date {
                    activeCount += 1
                    let statusScore = condition.currentStatus.scoreMultiplier
                    let ageMultiplier = calculateAgeMultiplier(condition, currentDate: date)
                    totalScore += condition.weight * statusScore * ageMultiplier * condition.confidenceScore
                }
            } else {
                // Check emerging conditions
                switch condition.currentStatus {
                case .emerging(let percentage):
                    if percentage > 0 {
                        activeCount += 1
                        totalScore += condition.weight * percentage * 0.5 * condition.confidenceScore
                    }
                    if condition.weight >= 8 && percentage < 0.5 {
                        criticalMissing.append(condition.scriptureReference)
                    }
                case .notMet:
                    if condition.weight >= 8 {
                        criticalMissing.append(condition.scriptureReference)
                    }
                default:
                    break
                }
            }
        }

        let percentage = (totalScore / maxPossibleScore) * 100
        let clockReading = convertToClockReading(percentage)
        let trend = calculateTrend(currentPercentage: percentage)
        let acceleration = calculateAcceleration()

        return ReadinessScore(
            percentage: percentage,
            clockReading: clockReading,
            trend: trend,
            acceleration: acceleration,
            activeConditions: activeCount,
            criticalMissing: criticalMissing
        )
    }

    private func calculateAgeMultiplier(_ condition: RaptureCondition, currentDate: Date) -> Float {
        guard let fulfillmentDate = condition.fulfillmentDate else { return 0.5 }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: fulfillmentDate, to: currentDate)
        let yearsActive = components.year ?? 0

        switch yearsActive {
        case 0..<5: return 0.6
        case 5..<10: return 0.7
        case 10..<25: return 0.85
        case 25..<50: return 0.95
        default: return 1.0
        }
    }

    private func convertToClockReading(_ percentage: Float) -> String {
        // Convert percentage to minutes before midnight
        // 100% = 11:59 PM (1 minute before midnight)
        // 0% = 9:00 PM (3 hours before midnight)
        let minutesBeforeMidnight = Int(180 - (percentage * 1.79)) // Maps 0-100% to 180-1 minutes
        let totalMinutesInDay = 24 * 60
        let clockMinutes = totalMinutesInDay - minutesBeforeMidnight

        let hours = (clockMinutes / 60) % 24
        let minutes = clockMinutes % 60

        let period = hours >= 12 ? "PM" : "AM"
        let displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours)

        return String(format: "%d:%02d %@", displayHours, minutes, period)
    }

    private func calculateTrend(currentPercentage: Float) -> ReadinessScore.Trend {
        // Compare with historical average
        if historicalScores.isEmpty {
            return .stable
        }

        let recentAverage = historicalScores.suffix(5).map { $0.score }.reduce(0, +) / Float(min(5, historicalScores.count))

        if currentPercentage > recentAverage + 2 {
            return .rising
        } else if currentPercentage < recentAverage - 2 {
            return .falling
        }
        return .stable
    }

    private func calculateAcceleration() -> Float {
        guard historicalScores.count >= 2 else { return 0 }

        let lastYear = historicalScores.last?.score ?? 0
        let previousYear = historicalScores[historicalScores.count - 2].score

        return lastYear - previousYear
    }

    private func calculateHistoricalData() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        historicalScores = []

        // Calculate scores for past 50 years
        for yearOffset in (0..<50).reversed() {
            let year = currentYear - yearOffset
            let date = calendar.date(from: DateComponents(year: year, month: 6, day: 15))!
            let score = calculateReadiness(for: date)
            historicalScores.append((year: year, score: score.percentage))
        }
    }

    func getCategoryScores() -> [Category: Float] {
        var scores: [Category: Float] = [:]

        for category in Category.allCases {
            let categoryConditions = conditions.filter { $0.category == category }
            var categoryScore: Float = 0
            var categoryMax: Float = 0

            for condition in categoryConditions {
                categoryMax += condition.weight
                if condition.isActiveInWindow {
                    categoryScore += condition.weight * condition.currentStatus.scoreMultiplier * condition.confidenceScore
                }
            }

            scores[category] = categoryMax > 0 ? (categoryScore / categoryMax) * 100 : 0
        }

        return scores
    }

    func getActiveConditionsForCategory(_ category: Category) -> [RaptureCondition] {
        return conditions.filter { $0.category == category && $0.isActiveInWindow }
    }

    func getCriticalActiveConditions() -> [RaptureCondition] {
        return conditions
            .filter { $0.isActiveInWindow && $0.weight >= 8 }
            .sorted { $0.weight > $1.weight }
            .prefix(5)
            .map { $0 }
    }

    func generatePrediction() -> Prediction {
        let criticalMissing = conditions.filter { condition in
            !condition.isActiveInWindow && condition.weight >= 8
        }

        let acceleration = calculateAcceleration()
        let projectedYears = acceleration > 0 ? Int(20 / acceleration) : 999

        let analysis = """
        Based on \(currentScore.activeConditions) active conditions within the current 100-year window, convergence is at \(String(format: "%.1f", currentScore.percentage))%.

        Critical fulfilled: Israel restoration (1948), Jerusalem control (1967), Knowledge explosion (2000s)

        Emerging rapidly: Global surveillance, Digital currency systems, AI consciousness

        Still developing: Third Temple, Peace covenant, Global government

        At current acceleration rate of \(String(format: "%.1f", acceleration))% per year, full convergence possible within \(projectedYears) years.
        """

        return Prediction(
            currentReading: currentScore.clockReading,
            confidence: currentScore.percentage > 85 ? "Very High" : currentScore.percentage > 70 ? "High" : "Moderate",
            criticalMissing: criticalMissing,
            projection: "Convergence accelerating at \(String(format: "%.1f", acceleration))% annually",
            analysis: analysis
        )
    }
}