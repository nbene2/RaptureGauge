import SwiftUI

@main
struct RaptureGaugeApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Main View with Countdown and Categories
struct MainView: View {
    @State private var selectedCategory: ProphecyCategory?
    @State private var raptureDate = Date().addingTimeInterval(681955200) // ~21.6 years from now
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark apocalyptic background
                LinearGradient(colors: [.black, .purple.opacity(0.2)],
                              startPoint: .top,
                              endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Countdown Timer Section
                    CountdownSection(raptureDate: raptureDate, currentTime: currentTime)
                        .padding(.vertical, 30)

                    // Category List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(ProphecyCategory.allCategories) { category in
                                CategoryRow(category: category)
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationDestination(item: $selectedCategory) { category in
                CategoryDetailView(category: category)
            }
            .onReceive(timer) { _ in
                currentTime = Date()
                updateRaptureEstimate()
            }
        }
    }

    func updateRaptureEstimate() {
        // Calculate based on prophecy fulfillment
        let totalProgress = ProphecyCategory.allCategories.reduce(0) { $0 + $1.progress } / 10.0

        // Estimate years remaining (exponentially decreasing as progress increases)
        let yearsRemaining = 100 * pow(1 - totalProgress, 2)
        raptureDate = Date().addingTimeInterval(yearsRemaining * 365.25 * 24 * 60 * 60)
    }
}

// MARK: - Countdown Timer Component
struct CountdownSection: View {
    let raptureDate: Date
    let currentTime: Date

    var timeRemaining: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                from: currentTime, to: raptureDate)

        return (
            years: components.year ?? 0,
            months: components.month ?? 0,
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("ESTIMATED TIME TO RAPTURE")
                .font(.caption)
                .foregroundColor(.gray)
                .tracking(2)

            HStack(spacing: 15) {
                TimeUnit(value: timeRemaining.years, label: "YEARS")
                TimeUnit(value: timeRemaining.months, label: "MONTHS")
                TimeUnit(value: timeRemaining.days, label: "DAYS")
            }

            HStack(spacing: 15) {
                TimeUnit(value: timeRemaining.hours, label: "HOURS")
                TimeUnit(value: timeRemaining.minutes, label: "MINUTES")
                TimeUnit(value: timeRemaining.seconds, label: "SECONDS", isSeconds: true)
            }

            // Overall Progress Bar
            ProgressView(value: calculateOverallProgress())
                .tint(.purple)
                .scaleEffect(x: 1, y: 2)
                .padding(.horizontal, 40)
                .padding(.top, 10)

            Text("\(Int(calculateOverallProgress() * 100))% of prophecies fulfilled")
                .font(.caption)
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    func calculateOverallProgress() -> Double {
        ProphecyCategory.allCategories.reduce(0) { $0 + $1.progress } / 10.0
    }
}

struct TimeUnit: View {
    let value: Int
    let label: String
    var isSeconds: Bool = false

    var body: some View {
        VStack(spacing: 5) {
            Text(String(format: "%02d", value))
                .font(.system(size: isSeconds ? 28 : 24, weight: .bold, design: .monospaced))
                .foregroundColor(isSeconds ? .red : .white)
                .animation(isSeconds ? .easeInOut(duration: 0.5) : nil, value: value)

            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
        .frame(minWidth: 50)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Category Row Component
struct CategoryRow: View {
    let category: ProphecyCategory

    var body: some View {
        HStack {
            // Icon
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .frame(width: 30)

            // Category Name
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(category.activeConditions)/\(category.totalConditions) conditions active")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Progress Indicator
            CircularProgressView(progress: category.progress, color: category.color)
                .frame(width: 50, height: 50)

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let category: ProphecyCategory
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, category.color.opacity(0.2)],
                          startPoint: .top,
                          endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: category.icon)
                            .font(.largeTitle)
                            .foregroundColor(category.color)

                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)

                            Text("\(category.activeConditions) of \(category.totalConditions) prophecies active")
                                .foregroundColor(category.color)
                        }

                        Spacer()
                    }
                    .padding()

                    // Prophecies Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("PROPHECIES")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        ForEach(category.prophecies) { prophecy in
                            ProphecyCard(prophecy: prophecy, categoryColor: category.color)
                        }
                    }

                    // Related Articles Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("TOP SCORING ARTICLES")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        ForEach(category.articles) { article in
                            ArticleCard(article: article, categoryColor: category.color)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(category.color)
                }
            }
        }
    }
}

struct ProphecyCard: View {
    let prophecy: Prophecy
    let categoryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(prophecy.reference)
                .font(.caption)
                .foregroundColor(categoryColor)

            Text(prophecy.quote)
                .font(.body)
                .foregroundColor(.white)
                .italic()

            HStack {
                Label("\(Int(prophecy.fulfillmentScore * 100))% fulfilled",
                      systemImage: prophecy.isActive ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(prophecy.isActive ? .green : .gray)

                Spacer()

                if prophecy.isActive {
                    Text("Since \(prophecy.activeSince ?? "")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ArticleCard: View {
    let article: NewsArticle
    let categoryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(article.source)
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text("\(Int(article.relevanceScore * 100))% match")
                    .font(.caption)
                    .foregroundColor(categoryColor)
            }

            Text(article.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)

            Text(article.summary)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(3)

            Text(article.date)
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Data Models
struct ProphecyCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let progress: Double
    let activeConditions: Int
    let totalConditions: Int
    let prophecies: [Prophecy]
    let articles: [NewsArticle]

    static let allCategories = [
        ProphecyCategory(
            name: "Israel & Jerusalem",
            icon: "star.of.david",
            color: .blue,
            progress: 0.95,
            activeConditions: 9,
            totalConditions: 10,
            prophecies: Prophecy.israelProphecies,
            articles: NewsArticle.israelArticles
        ),
        ProphecyCategory(
            name: "Technology & Control",
            icon: "cpu",
            color: .green,
            progress: 0.85,
            activeConditions: 7,
            totalConditions: 8,
            prophecies: Prophecy.techProphecies,
            articles: NewsArticle.techArticles
        ),
        ProphecyCategory(
            name: "Natural Disasters",
            icon: "tornado",
            color: .orange,
            progress: 0.70,
            activeConditions: 6,
            totalConditions: 9,
            prophecies: Prophecy.disasterProphecies,
            articles: NewsArticle.disasterArticles
        ),
        ProphecyCategory(
            name: "Wars & Conflicts",
            icon: "flame",
            color: .red,
            progress: 0.80,
            activeConditions: 8,
            totalConditions: 10,
            prophecies: Prophecy.warProphecies,
            articles: NewsArticle.warArticles
        ),
        ProphecyCategory(
            name: "Global Government",
            icon: "globe",
            color: .purple,
            progress: 0.60,
            activeConditions: 5,
            totalConditions: 8,
            prophecies: [],
            articles: []
        ),
        ProphecyCategory(
            name: "Religious Apostasy",
            icon: "building.columns",
            color: .pink,
            progress: 0.75,
            activeConditions: 6,
            totalConditions: 8,
            prophecies: [],
            articles: []
        ),
        ProphecyCategory(
            name: "Knowledge Increase",
            icon: "brain",
            color: .cyan,
            progress: 0.90,
            activeConditions: 9,
            totalConditions: 10,
            prophecies: [],
            articles: []
        ),
        ProphecyCategory(
            name: "Moral Decay",
            icon: "arrow.down.circle",
            color: .gray,
            progress: 0.85,
            activeConditions: 8,
            totalConditions: 9,
            prophecies: [],
            articles: []
        ),
        ProphecyCategory(
            name: "Economic Signs",
            icon: "dollarsign.circle",
            color: .yellow,
            progress: 0.65,
            activeConditions: 5,
            totalConditions: 8,
            prophecies: [],
            articles: []
        ),
        ProphecyCategory(
            name: "Persecution",
            icon: "cross.fill",
            color: .indigo,
            progress: 0.55,
            activeConditions: 4,
            totalConditions: 7,
            prophecies: [],
            articles: []
        )
    ]
}

struct Prophecy: Identifiable {
    let id = UUID()
    let reference: String
    let quote: String
    let fulfillmentScore: Double
    let isActive: Bool
    let activeSince: String?

    static let israelProphecies = [
        Prophecy(
            reference: "Ezekiel 37:21-22",
            quote: "I will gather the Israelites from among the nations... and bring them to their own land.",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1948"
        ),
        Prophecy(
            reference: "Luke 21:24",
            quote: "Jerusalem will be trampled on by the Gentiles until the times of the Gentiles are fulfilled.",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1967"
        ),
        Prophecy(
            reference: "Isaiah 66:8",
            quote: "Who has ever heard of such things? Can a country be born in a day?",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1948"
        )
    ]

    static let techProphecies = [
        Prophecy(
            reference: "Revelation 13:16-17",
            quote: "No one could buy or sell unless they had the mark...",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "2020"
        ),
        Prophecy(
            reference: "Daniel 12:4",
            quote: "Knowledge shall increase",
            fulfillmentScore: 0.95,
            isActive: true,
            activeSince: "1990"
        )
    ]

    static let disasterProphecies = [
        Prophecy(
            reference: "Matthew 24:7",
            quote: "There will be earthquakes in various places",
            fulfillmentScore: 0.70,
            isActive: true,
            activeSince: "2010"
        )
    ]

    static let warProphecies = [
        Prophecy(
            reference: "Matthew 24:6",
            quote: "You will hear of wars and rumors of wars",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "2022"
        )
    ]
}

struct NewsArticle: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let date: String
    let relevanceScore: Double

    static let israelArticles = [
        NewsArticle(
            title: "Historic Peace Accord Discussions in Middle East",
            summary: "Nations gather to discuss unprecedented peace treaty involving Israel...",
            source: "Reuters",
            date: "2 hours ago",
            relevanceScore: 0.92
        ),
        NewsArticle(
            title: "Temple Mount Archaeological Discovery",
            summary: "New findings at Temple Mount site reveal ancient artifacts from Second Temple period...",
            source: "Jerusalem Post",
            date: "1 day ago",
            relevanceScore: 0.88
        )
    ]

    static let techArticles = [
        NewsArticle(
            title: "Central Banks Announce Digital Currency Timeline",
            summary: "Major economies commit to CBDC implementation by 2025...",
            source: "Financial Times",
            date: "5 hours ago",
            relevanceScore: 0.95
        ),
        NewsArticle(
            title: "AI System Achieves Human-Level Reasoning",
            summary: "Breakthrough in artificial general intelligence raises questions...",
            source: "MIT Technology Review",
            date: "12 hours ago",
            relevanceScore: 0.87
        )
    ]

    static let disasterArticles = [
        NewsArticle(
            title: "Record Number of Earthquakes Recorded Globally",
            summary: "Seismic activity increases 300% compared to historical average...",
            source: "USGS",
            date: "3 days ago",
            relevanceScore: 0.78
        )
    ]

    static let warArticles = [
        NewsArticle(
            title: "Military Alliance Forms in Eastern Region",
            summary: "Multiple nations join defensive pact amid rising tensions...",
            source: "BBC News",
            date: "6 hours ago",
            relevanceScore: 0.85
        )
    ]
}

// Add star.of.david SF Symbol alternative
extension Image {
    init(systemName: String) {
        if systemName == "star.of.david" {
            self = Image(systemName: "star")
        } else if systemName == "cross.fill" {
            self = Image(systemName: "plus.circle.fill")
        } else {
            self = Image(systemName: systemName)
        }
    }
}