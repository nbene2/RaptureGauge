import Foundation

// MARK: - Pre-populated Biblical Conditions

class ConditionData {
    static let shared = ConditionData()

    private init() {}

    func getAllConditions() -> [RaptureCondition] {
        return [
            // ISRAEL & JERUSALEM (Weight 10)
            RaptureCondition(
                category: .israelJerusalem,
                scriptureReference: "Ezekiel 36:24",
                scriptureQuote: "I will take you from among the nations, gather you out of all countries",
                weight: 10,
                currentStatus: .fulfilled(date: dateFrom("1948-05-14")),
                fulfillmentDate: dateFrom("1948-05-14"),
                confidenceScore: 1.0,
                dataSource: "Historical record - Israel declared independence"
            ),
            RaptureCondition(
                category: .israelJerusalem,
                scriptureReference: "Isaiah 66:8",
                scriptureQuote: "A nation born in one day",
                weight: 10,
                currentStatus: .fulfilled(date: dateFrom("1948-05-14")),
                fulfillmentDate: dateFrom("1948-05-14"),
                confidenceScore: 1.0,
                dataSource: "Historical record"
            ),
            RaptureCondition(
                category: .israelJerusalem,
                scriptureReference: "Luke 21:24",
                scriptureQuote: "Jerusalem will be trampled on by the Gentiles until...",
                weight: 10,
                currentStatus: .fulfilled(date: dateFrom("1967-06-07")),
                fulfillmentDate: dateFrom("1967-06-07"),
                confidenceScore: 1.0,
                dataSource: "Six-Day War - Jerusalem reunified"
            ),
            RaptureCondition(
                category: .israelJerusalem,
                scriptureReference: "Zechariah 12:3",
                scriptureQuote: "Jerusalem a burdensome stone for all people",
                weight: 9,
                currentStatus: .active(since: dateFrom("1967-06-07")),
                fulfillmentDate: dateFrom("1967-06-07"),
                confidenceScore: 0.95,
                dataSource: "UN resolutions, international disputes"
            ),

            // TECHNOLOGY & CONTROL (Weight 9)
            RaptureCondition(
                category: .technology,
                scriptureReference: "Revelation 13:17",
                scriptureQuote: "No man might buy or sell without the mark",
                weight: 9,
                currentStatus: .emerging(percentage: 0.75),
                fulfillmentDate: nil,
                confidenceScore: 0.8,
                dataSource: "CBDCs, digital payments, cashless society trends"
            ),
            RaptureCondition(
                category: .technology,
                scriptureReference: "Revelation 13:15",
                scriptureQuote: "He had power to give life unto the image",
                weight: 8,
                currentStatus: .emerging(percentage: 0.85),
                fulfillmentDate: nil,
                confidenceScore: 0.85,
                dataSource: "AI advancement, deepfakes, virtual beings"
            ),
            RaptureCondition(
                category: .technology,
                scriptureReference: "Daniel 12:4",
                scriptureQuote: "Knowledge shall be increased",
                weight: 7,
                currentStatus: .fulfilled(date: dateFrom("2000-01-01")),
                fulfillmentDate: dateFrom("2000-01-01"),
                confidenceScore: 1.0,
                dataSource: "Internet, information explosion"
            ),

            // GEOPOLITICAL ALIGNMENTS (Weight 8)
            RaptureCondition(
                category: .geopolitical,
                scriptureReference: "Ezekiel 38:5",
                scriptureQuote: "Persia, Ethiopia, and Libya with them",
                weight: 8,
                currentStatus: .active(since: dateFrom("2015-01-01")),
                fulfillmentDate: dateFrom("2015-01-01"),
                confidenceScore: 0.85,
                dataSource: "Russia-Iran-Turkey cooperation"
            ),
            RaptureCondition(
                category: .geopolitical,
                scriptureReference: "Matthew 24:7",
                scriptureQuote: "Nation shall rise against nation",
                weight: 7,
                currentStatus: .active(since: dateFrom("1914-01-01")),
                fulfillmentDate: dateFrom("1914-01-01"),
                confidenceScore: 1.0,
                dataSource: "WWI, WWII, ongoing conflicts"
            ),
            RaptureCondition(
                category: .geopolitical,
                scriptureReference: "Revelation 16:12",
                scriptureQuote: "The kings from the East",
                weight: 7,
                currentStatus: .emerging(percentage: 0.7),
                fulfillmentDate: nil,
                confidenceScore: 0.75,
                dataSource: "China's rise, Asian military buildup"
            ),

            // NATURAL DISASTERS (Weight 7)
            RaptureCondition(
                category: .naturalDisasters,
                scriptureReference: "Luke 21:11",
                scriptureQuote: "Great earthquakes shall be in divers places",
                weight: 7,
                currentStatus: .active(since: dateFrom("1900-01-01")),
                fulfillmentDate: dateFrom("1900-01-01"),
                confidenceScore: 0.9,
                dataSource: "USGS data - increasing frequency"
            ),
            RaptureCondition(
                category: .naturalDisasters,
                scriptureReference: "Matthew 24:7",
                scriptureQuote: "There shall be famines, and pestilences",
                weight: 7,
                currentStatus: .active(since: dateFrom("2020-01-01")),
                fulfillmentDate: dateFrom("2020-01-01"),
                confidenceScore: 0.85,
                dataSource: "COVID-19, food supply disruptions"
            ),

            // MORAL DECLINE (Weight 6)
            RaptureCondition(
                category: .moralDecline,
                scriptureReference: "2 Timothy 3:1-5",
                scriptureQuote: "In the last days perilous times shall come",
                weight: 6,
                currentStatus: .active(since: dateFrom("1960-01-01")),
                fulfillmentDate: dateFrom("1960-01-01"),
                confidenceScore: 0.8,
                dataSource: "Cultural indicators, moral statistics"
            ),
            RaptureCondition(
                category: .moralDecline,
                scriptureReference: "Matthew 24:12",
                scriptureQuote: "The love of many shall wax cold",
                weight: 6,
                currentStatus: .emerging(percentage: 0.7),
                fulfillmentDate: nil,
                confidenceScore: 0.75,
                dataSource: "Social polarization, declining empathy"
            ),

            // GOSPEL REACH (Weight 8)
            RaptureCondition(
                category: .gospelReach,
                scriptureReference: "Matthew 24:14",
                scriptureQuote: "Gospel preached in all the world",
                weight: 8,
                currentStatus: .emerging(percentage: 0.92),
                fulfillmentDate: nil,
                confidenceScore: 0.95,
                dataSource: "Joshua Project - 95% reached"
            ),

            // PERSECUTION (Weight 5)
            RaptureCondition(
                category: .persecution,
                scriptureReference: "Matthew 24:9",
                scriptureQuote: "Ye shall be hated of all nations",
                weight: 5,
                currentStatus: .active(since: dateFrom("2000-01-01")),
                fulfillmentDate: dateFrom("2000-01-01"),
                confidenceScore: 0.8,
                dataSource: "Open Doors persecution index"
            ),

            // FALSE PROPHETS & DECEPTION (Weight 6)
            RaptureCondition(
                category: .deception,
                scriptureReference: "Matthew 24:11",
                scriptureQuote: "Many false prophets shall rise",
                weight: 6,
                currentStatus: .active(since: dateFrom("1970-01-01")),
                fulfillmentDate: dateFrom("1970-01-01"),
                confidenceScore: 0.85,
                dataSource: "New Age, cults, false teachings"
            ),
            RaptureCondition(
                category: .deception,
                scriptureReference: "2 Peter 3:3",
                scriptureQuote: "There shall come scoffers",
                weight: 5,
                currentStatus: .active(since: dateFrom("1859-01-01")),
                fulfillmentDate: dateFrom("1859-01-01"),
                confidenceScore: 0.9,
                dataSource: "Post-Darwin secular worldview"
            ),

            // TEMPLE PREPARATION (Weight 9)
            RaptureCondition(
                category: .templePrep,
                scriptureReference: "Daniel 9:27",
                scriptureQuote: "He shall confirm the covenant",
                weight: 9,
                currentStatus: .notMet,
                fulfillmentDate: nil,
                confidenceScore: 0.0,
                dataSource: "No peace covenant yet"
            ),
            RaptureCondition(
                category: .templePrep,
                scriptureReference: "2 Thessalonians 2:4",
                scriptureQuote: "He sits in the temple of God",
                weight: 9,
                currentStatus: .emerging(percentage: 0.3),
                fulfillmentDate: nil,
                confidenceScore: 0.4,
                dataSource: "Temple Institute preparations"
            ),
            RaptureCondition(
                category: .templePrep,
                scriptureReference: "Numbers 19",
                scriptureQuote: "Red heifer for purification",
                weight: 7,
                currentStatus: .emerging(percentage: 0.9),
                fulfillmentDate: nil,
                confidenceScore: 0.9,
                dataSource: "Red heifers in Israel 2022"
            ),

            // GLOBAL SIGNS (Weight 7)
            RaptureCondition(
                category: .globalSigns,
                scriptureReference: "Luke 21:25",
                scriptureQuote: "Distress of nations, with perplexity",
                weight: 7,
                currentStatus: .active(since: dateFrom("2020-01-01")),
                fulfillmentDate: dateFrom("2020-01-01"),
                confidenceScore: 0.85,
                dataSource: "Global anxiety, mental health crisis"
            ),
            RaptureCondition(
                category: .globalSigns,
                scriptureReference: "1 Thessalonians 5:3",
                scriptureQuote: "When they say Peace and safety",
                weight: 7,
                currentStatus: .emerging(percentage: 0.6),
                fulfillmentDate: nil,
                confidenceScore: 0.7,
                dataSource: "UN peace initiatives, global security efforts"
            ),
            RaptureCondition(
                category: .globalSigns,
                scriptureReference: "Revelation 13:7",
                scriptureQuote: "Authority over every tribe and nation",
                weight: 8,
                currentStatus: .emerging(percentage: 0.5),
                fulfillmentDate: nil,
                confidenceScore: 0.6,
                dataSource: "Global governance initiatives"
            )
        ]
    }

    private func dateFrom(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }
}