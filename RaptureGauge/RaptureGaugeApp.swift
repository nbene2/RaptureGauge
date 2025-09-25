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
    @State private var showingDetail = false
    @State private var raptureDate = Date().addingTimeInterval(681955200) // ~21.6 years from now
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ZStack {
                // Dark apocalyptic background
                LinearGradient(colors: [.black, .purple.opacity(0.2)],
                              startPoint: .top,
                              endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Logo and Title
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.top, 20)

                    Text("RAPTUREX")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .tracking(3)
                        .padding(.bottom, 10)

                    // Countdown Timer Section
                    CountdownSection(raptureDate: raptureDate, currentTime: currentTime)
                        .padding(.vertical, 30)

                    // Category List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(ProphecyCategory.allCategories) { category in
                                NavigationLink(destination: CategoryDetailView(category: category)) {
                                    CategoryRow(category: category)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                currentTime = Date()
                updateRaptureEstimate()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    @Environment(\.presentationMode) var presentationMode

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
        .navigationBarItems(
            leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(category.color)
            }
        )
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
struct ProphecyCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let progress: Double
    let activeConditions: Int
    let totalConditions: Int
    let prophecies: [Prophecy]
    let articles: [NewsArticle]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ProphecyCategory, rhs: ProphecyCategory) -> Bool {
        lhs.id == rhs.id
    }

    static let allCategories = [
        ProphecyCategory(
            name: "Israel & Jerusalem",
            icon: "star",
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
            prophecies: Prophecy.globalGovProphecies,
            articles: []
        ),
        ProphecyCategory(
            name: "Religious Apostasy",
            icon: "building.columns",
            color: .pink,
            progress: 0.75,
            activeConditions: 6,
            totalConditions: 8,
            prophecies: Prophecy.apostasyProphecies,
            articles: []
        ),
        ProphecyCategory(
            name: "Knowledge Increase",
            icon: "brain",
            color: .cyan,
            progress: 0.90,
            activeConditions: 9,
            totalConditions: 10,
            prophecies: Prophecy.knowledgeProphecies,
            articles: []
        ),
        ProphecyCategory(
            name: "Moral Decay",
            icon: "arrow.down.circle",
            color: .gray,
            progress: 0.85,
            activeConditions: 8,
            totalConditions: 9,
            prophecies: Prophecy.moralDecayProphecies,
            articles: []
        ),
        ProphecyCategory(
            name: "Economic Signs",
            icon: "dollarsign.circle",
            color: .yellow,
            progress: 0.65,
            activeConditions: 5,
            totalConditions: 8,
            prophecies: Prophecy.economicProphecies,
            articles: []
        ),
        ProphecyCategory(
            name: "Persecution",
            icon: "plus.circle.fill",
            color: .indigo,
            progress: 0.55,
            activeConditions: 4,
            totalConditions: 7,
            prophecies: Prophecy.persecutionProphecies,
            articles: []
        )
    ]
}

struct Prophecy: Identifiable, Hashable {
    let id = UUID()
    let reference: String
    let quote: String
    let fulfillmentScore: Double
    let isActive: Bool
    let activeSince: String?

    static let israelProphecies = [
        Prophecy(
            reference: "Ezekiel 36:24",
            quote: "I will take you from among the nations, gather you out of all countries, and bring you into your own land",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1948"
        ),
        Prophecy(
            reference: "Isaiah 66:8",
            quote: "A nation born in one day",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1948"
        ),
        Prophecy(
            reference: "Luke 21:24",
            quote: "Jerusalem will be trampled on by the Gentiles until the times of the Gentiles are fulfilled",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1967"
        ),
        Prophecy(
            reference: "Zechariah 12:2",
            quote: "I will make Jerusalem a cup of trembling unto all the people round about",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "1967"
        ),
        Prophecy(
            reference: "Zechariah 12:3",
            quote: "In that day will I make Jerusalem a burdensome stone for all people",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "1967"
        ),
        Prophecy(
            reference: "Daniel 9:27",
            quote: "He will confirm a covenant with many for one 'seven.' In the middle of the 'seven' he will put an end to sacrifice",
            fulfillmentScore: 0.10,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "2 Thessalonians 2:4",
            quote: "The man of lawlessness... will sit in the temple of God",
            fulfillmentScore: 0.05,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Matthew 24:15",
            quote: "When you see standing in the holy place 'the abomination that causes desolation'",
            fulfillmentScore: 0.0,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Numbers 19",
            quote: "Red heifer for purification",
            fulfillmentScore: 0.75,
            isActive: true,
            activeSince: "2022"
        ),
        Prophecy(
            reference: "Jeremiah 16:15",
            quote: "I will bring them back to the land I gave to their ancestors",
            fulfillmentScore: 0.95,
            isActive: true,
            activeSince: "1948"
        ),
        Prophecy(
            reference: "Isaiah 11:11-12",
            quote: "Second regathering from all nations",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "1948"
        ),
        Prophecy(
            reference: "Ezekiel 37:21-22",
            quote: "Making them one nation in the land",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "1948"
        ),
        Prophecy(
            reference: "Zechariah 14:2",
            quote: "All nations gathered against Jerusalem",
            fulfillmentScore: 0.40,
            isActive: false,
            activeSince: nil
        )
    ]

    static let techProphecies = [
        Prophecy(
            reference: "Revelation 13:16-17",
            quote: "He causeth all... to receive a mark in their right hand, or in their foreheads... No man might buy or sell, save he that had the mark",
            fulfillmentScore: 0.75,
            isActive: true,
            activeSince: "2020"
        ),
        Prophecy(
            reference: "Daniel 12:4",
            quote: "Many shall run to and fro, and knowledge shall be increased",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1990"
        ),
        Prophecy(
            reference: "Revelation 13:18",
            quote: "The number of the beast... Six hundred threescore and six",
            fulfillmentScore: 0.60,
            isActive: true,
            activeSince: "1970"
        ),
        Prophecy(
            reference: "Revelation 13:15",
            quote: "He had power to give life unto the image of the beast... The image of the beast should both speak",
            fulfillmentScore: 0.70,
            isActive: true,
            activeSince: "2023"
        ),
        Prophecy(
            reference: "Revelation 18:17",
            quote: "In one hour so great riches is come to nought",
            fulfillmentScore: 0.65,
            isActive: true,
            activeSince: "2008"
        )
    ]

    static let disasterProphecies = [
        Prophecy(
            reference: "Luke 21:11",
            quote: "There will be great earthquakes",
            fulfillmentScore: 0.75,
            isActive: true,
            activeSince: "2004"
        ),
        Prophecy(
            reference: "Matthew 24:7",
            quote: "There will be famines and earthquakes in various places",
            fulfillmentScore: 0.70,
            isActive: true,
            activeSince: "2010"
        ),
        Prophecy(
            reference: "Luke 21:11",
            quote: "Pestilences in various places",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "2020"
        ),
        Prophecy(
            reference: "Revelation 6:8",
            quote: "Death was given power over a fourth of the earth",
            fulfillmentScore: 0.30,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Matthew 24:29",
            quote: "The sun will be darkened, and the moon will not give its light",
            fulfillmentScore: 0.10,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Joel 2:31",
            quote: "The moon turned blood red",
            fulfillmentScore: 0.35,
            isActive: true,
            activeSince: "2014"
        ),
        Prophecy(
            reference: "Luke 21:11",
            quote: "Fearful events and great signs from heaven",
            fulfillmentScore: 0.40,
            isActive: true,
            activeSince: "2020"
        ),
        Prophecy(
            reference: "Luke 21:25",
            quote: "The sea and the waves roaring",
            fulfillmentScore: 0.60,
            isActive: true,
            activeSince: "2000"
        ),
        Prophecy(
            reference: "Revelation 8:8",
            quote: "A third of the sea turned into blood",
            fulfillmentScore: 0.15,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Revelation 8:11",
            quote: "A third of the waters turned bitter",
            fulfillmentScore: 0.20,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Revelation 16:12",
            quote: "The Euphrates river was dried up",
            fulfillmentScore: 0.45,
            isActive: true,
            activeSince: "2021"
        ),
        Prophecy(
            reference: "Revelation 16:18-20",
            quote: "A great earthquake... and every island fled away",
            fulfillmentScore: 0.05,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Revelation 6:6",
            quote: "A quart of wheat for a day's wages",
            fulfillmentScore: 0.55,
            isActive: true,
            activeSince: "2022"
        )
    ]

    static let warProphecies = [
        Prophecy(
            reference: "Matthew 24:6",
            quote: "You will hear of wars and rumors of wars",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "2022"
        ),
        Prophecy(
            reference: "Matthew 24:7",
            quote: "Nation will rise against nation, and kingdom against kingdom",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "1914"
        ),
        Prophecy(
            reference: "Ezekiel 38:2-5",
            quote: "Gog, of the land of Magog... Persia, Cush and Put will be with them",
            fulfillmentScore: 0.70,
            isActive: true,
            activeSince: "2015"
        ),
        Prophecy(
            reference: "Ezekiel 38:6",
            quote: "Gomer and all its troops... Beth Togarmah from the far north",
            fulfillmentScore: 0.65,
            isActive: true,
            activeSince: "2016"
        ),
        Prophecy(
            reference: "Revelation 16:12",
            quote: "The kings from the East",
            fulfillmentScore: 0.65,
            isActive: true,
            activeSince: "2020"
        ),
        Prophecy(
            reference: "Daniel 11:40",
            quote: "The king of the North... the king of the South",
            fulfillmentScore: 0.55,
            isActive: true,
            activeSince: "2011"
        ),
        Prophecy(
            reference: "Revelation 16:14",
            quote: "The battle of that great day of God Almighty",
            fulfillmentScore: 0.15,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Revelation 16:16",
            quote: "He gathered them together into a place called... Armageddon",
            fulfillmentScore: 0.20,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Zechariah 14:2",
            quote: "I will gather all nations against Jerusalem to battle",
            fulfillmentScore: 0.35,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "1 Thessalonians 5:3",
            quote: "When they shall say, Peace and safety; then sudden destruction",
            fulfillmentScore: 0.50,
            isActive: true,
            activeSince: "2020"
        )
    ]

    static let globalGovProphecies = [
        Prophecy(
            reference: "Revelation 13:7",
            quote: "Authority over every tribe, people, language and nation",
            fulfillmentScore: 0.55,
            isActive: true,
            activeSince: "1945"
        ),
        Prophecy(
            reference: "Revelation 13:8",
            quote: "All inhabitants of the earth will worship the beast",
            fulfillmentScore: 0.20,
            isActive: false,
            activeSince: nil
        ),
        Prophecy(
            reference: "Revelation 17:12",
            quote: "Ten kings who have not yet received a kingdom",
            fulfillmentScore: 0.60,
            isActive: true,
            activeSince: "1957"
        ),
        Prophecy(
            reference: "Daniel 7:24",
            quote: "Ten-nation confederacy",
            fulfillmentScore: 0.65,
            isActive: true,
            activeSince: "1993"
        )
    ]

    static let apostasyProphecies = [
        Prophecy(
            reference: "2 Thessalonians 2:3",
            quote: "The falling away comes first",
            fulfillmentScore: 0.75,
            isActive: true,
            activeSince: "1960"
        ),
        Prophecy(
            reference: "1 Timothy 4:1",
            quote: "Some shall depart from the faith",
            fulfillmentScore: 0.80,
            isActive: true,
            activeSince: "1970"
        ),
        Prophecy(
            reference: "Matthew 24:12",
            quote: "Because iniquity shall abound, the love of many shall wax cold",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "2000"
        ),
        Prophecy(
            reference: "2 Timothy 3:5",
            quote: "Having a form of godliness but denying its power",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "1990"
        ),
        Prophecy(
            reference: "2 Peter 3:3",
            quote: "There shall come in the last days scoffers",
            fulfillmentScore: 0.95,
            isActive: true,
            activeSince: "1859"
        )
    ]

    static let knowledgeProphecies = [
        Prophecy(
            reference: "Daniel 12:4",
            quote: "Many shall run to and fro, and knowledge shall be increased",
            fulfillmentScore: 1.0,
            isActive: true,
            activeSince: "1900"
        ),
        Prophecy(
            reference: "Revelation 11:9",
            quote: "People from every tribe, language and nation will gaze on their bodies",
            fulfillmentScore: 0.95,
            isActive: true,
            activeSince: "1960"
        ),
        Prophecy(
            reference: "Matthew 24:14",
            quote: "This gospel of the kingdom shall be preached in all the world",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "1950"
        )
    ]

    static let moralDecayProphecies = [
        Prophecy(
            reference: "2 Timothy 3:1-5",
            quote: "Lovers of their own selves, covetous, boasters, proud, blasphemers",
            fulfillmentScore: 0.90,
            isActive: true,
            activeSince: "1960"
        ),
        Prophecy(
            reference: "Matthew 24:37",
            quote: "As it was in the days of Noah",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "1970"
        ),
        Prophecy(
            reference: "Luke 17:28",
            quote: "As it was in the days of Lot",
            fulfillmentScore: 0.80,
            isActive: true,
            activeSince: "1980"
        ),
        Prophecy(
            reference: "2 Timothy 3:2",
            quote: "Disobedient to parents",
            fulfillmentScore: 0.95,
            isActive: true,
            activeSince: "1960"
        )
    ]

    static let economicProphecies = [
        Prophecy(
            reference: "Revelation 6:6",
            quote: "A quart of wheat for a day's wages",
            fulfillmentScore: 0.60,
            isActive: true,
            activeSince: "2008"
        ),
        Prophecy(
            reference: "James 5:3",
            quote: "Ye have heaped treasure together for the last days",
            fulfillmentScore: 0.75,
            isActive: true,
            activeSince: "1980"
        ),
        Prophecy(
            reference: "Revelation 18:3",
            quote: "The merchants of the earth are waxed rich",
            fulfillmentScore: 0.85,
            isActive: true,
            activeSince: "1990"
        )
    ]

    static let persecutionProphecies = [
        Prophecy(
            reference: "Matthew 24:9",
            quote: "Ye shall be hated of all nations for my name's sake",
            fulfillmentScore: 0.70,
            isActive: true,
            activeSince: "33"
        ),
        Prophecy(
            reference: "Revelation 6:9",
            quote: "I saw under the altar the souls of them that were slain for the word of God",
            fulfillmentScore: 0.60,
            isActive: true,
            activeSince: "2000"
        ),
        Prophecy(
            reference: "Mark 13:12",
            quote: "Brother shall deliver up the brother to death",
            fulfillmentScore: 0.50,
            isActive: true,
            activeSince: "2010"
        )
    ]
}

struct NewsArticle: Identifiable, Hashable {
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