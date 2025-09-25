import Foundation

// MARK: - Core Data Models

struct RaptureCondition: Identifiable, Codable {
    var id: UUID
    let category: Category
    let scriptureReference: String
    let scriptureQuote: String
    let weight: Float

    var currentStatus: ConditionStatus
    var fulfillmentDate: Date?
    var expiryDate: Date?
    var confidenceScore: Float
    var dataSource: String

    var isActiveInWindow: Bool {
        guard let fulfillmentDate = fulfillmentDate else { return false }
        let windowStart = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        return fulfillmentDate >= windowStart
    }
}

enum ConditionStatus: Codable {
    case notMet
    case emerging(percentage: Float)
    case active(since: Date)
    case fulfilled(date: Date)
    case expired

    var scoreMultiplier: Float {
        switch self {
        case .notMet, .expired:
            return 0.0
        case .emerging(let percentage):
            return percentage
        case .active:
            return 0.8
        case .fulfilled:
            return 1.0
        }
    }
}

enum Category: String, CaseIterable, Codable {
    case israelJerusalem = "Israel & Jerusalem"
    case technology = "Technology & Control"
    case geopolitical = "Geopolitical"
    case naturalDisasters = "Natural Disasters"
    case moralDecline = "Moral Decline"
    case gospelReach = "Gospel Reach"
    case persecution = "Persecution"
    case deception = "False Prophets"
    case templePrep = "Temple Preparation"
    case globalSigns = "Global Signs"

    var weight: Float {
        switch self {
        case .israelJerusalem, .templePrep: return 10.0
        case .technology: return 9.0
        case .geopolitical, .gospelReach: return 8.0
        case .naturalDisasters, .globalSigns: return 7.0
        case .moralDecline, .deception: return 6.0
        case .persecution: return 5.0
        }
    }

    var color: String {
        switch self {
        case .israelJerusalem: return "blue"
        case .technology: return "purple"
        case .geopolitical: return "red"
        case .naturalDisasters: return "orange"
        case .moralDecline: return "gray"
        case .gospelReach: return "green"
        case .persecution: return "red"
        case .deception: return "yellow"
        case .templePrep: return "indigo"
        case .globalSigns: return "cyan"
        }
    }
}

struct ReadinessScore {
    let percentage: Float
    let clockReading: String
    let trend: Trend
    let acceleration: Float
    let activeConditions: Int
    let criticalMissing: [String]

    enum Trend: String {
        case rising = "↑"
        case falling = "↓"
        case stable = "→"
    }
}

struct Prediction {
    let currentReading: String
    let confidence: String
    let criticalMissing: [RaptureCondition]
    let projection: String
    let analysis: String
}