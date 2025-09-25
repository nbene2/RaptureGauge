import Foundation

final class USGSClient: Sendable {
    private let baseURL = "https://earthquake.usgs.gov/fdsnws/event/1"

    struct Earthquake: Codable, Identifiable {
        let id: String
        let magnitude: Float
        let location: String
        let latitude: Double
        let longitude: Double
        let depth: Float
        let time: Date
        let significantRadius: Float // Affected area

        var isSignificant: Bool {
            magnitude >= 5.0
        }

        var isMajor: Bool {
            magnitude >= 7.0
        }

        var isPropheticallyRelevant: Bool {
            // Check if near prophetic regions
            let nearJerusalem = isNear(lat: 31.7683, lon: 35.2137, radius: 500) // 500km from Jerusalem
            let nearMediterranean = longitude > -10 && longitude < 40 && latitude > 30 && latitude < 45
            let nearRingOfFire = (longitude > 100 && longitude < 180) || (longitude > -180 && longitude < -60)

            return magnitude >= 5.0 && (nearJerusalem || nearMediterranean || nearRingOfFire)
        }

        private func isNear(lat: Double, lon: Double, radius: Double) -> Bool {
            let distance = calculateDistance(lat1: latitude, lon1: longitude, lat2: lat, lon2: lon)
            return distance <= radius
        }

        private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
            // Simple distance calculation (in km)
            let R = 6371.0 // Earth's radius in km
            let dLat = (lat2 - lat1) * .pi / 180
            let dLon = (lon2 - lon1) * .pi / 180
            let a = sin(dLat/2) * sin(dLat/2) +
                    cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                    sin(dLon/2) * sin(dLon/2)
            let c = 2 * atan2(sqrt(a), sqrt(1-a))
            return R * c
        }
    }

    struct USGSResponse: Codable {
        let features: [Feature]

        struct Feature: Codable {
            let id: String
            let properties: Properties
            let geometry: Geometry

            struct Properties: Codable {
                let mag: Float?
                let place: String?
                let time: Int64
                let sig: Int?
            }

            struct Geometry: Codable {
                let coordinates: [Double]
            }
        }
    }

    func fetchRecentEarthquakes(minMagnitude: Float = 5.0, days: Int = 7) async throws -> [Earthquake] {
        let endTime = Date()
        let startTime = Calendar.current.date(byAdding: .day, value: -days, to: endTime)!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let params = [
            "format": "geojson",
            "minmagnitude": String(minMagnitude),
            "starttime": formatter.string(from: startTime),
            "endtime": formatter.string(from: endTime),
            "orderby": "time-asc"
        ]

        var components = URLComponents(string: "\(baseURL)/query")!
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let usgsResponse = try JSONDecoder().decode(USGSResponse.self, from: data)

        return usgsResponse.features.compactMap { feature in
            guard let magnitude = feature.properties.mag,
                  let place = feature.properties.place,
                  feature.geometry.coordinates.count >= 3 else {
                return nil
            }

            return Earthquake(
                id: feature.id,
                magnitude: magnitude,
                location: place,
                latitude: feature.geometry.coordinates[1],
                longitude: feature.geometry.coordinates[0],
                depth: Float(feature.geometry.coordinates[2]),
                time: Date(timeIntervalSince1970: TimeInterval(feature.properties.time / 1000)),
                significantRadius: Float(feature.properties.sig ?? 0)
            )
        }
    }

    func fetchMajorEarthquakes() async throws -> [Earthquake] {
        return try await fetchRecentEarthquakes(minMagnitude: 7.0, days: 30)
    }

    func calculateEarthquakeFrequency(over days: Int = 365) async throws -> EarthquakeFrequency {
        let earthquakes = try await fetchRecentEarthquakes(minMagnitude: 4.5, days: days)

        let byMagnitude = Dictionary(grouping: earthquakes) { quake in
            Int(quake.magnitude)
        }

        let diverseLocations = Set(earthquakes.map { quake in
            // Group by rough geographic region (10-degree grid)
            "\(Int(quake.latitude / 10))_\(Int(quake.longitude / 10))"
        }).count

        let averagePerMonth = Float(earthquakes.count) / Float(days / 30)

        return EarthquakeFrequency(
            total: earthquakes.count,
            byMagnitude: byMagnitude.mapValues { $0.count },
            diverseLocations: diverseLocations,
            averagePerMonth: averagePerMonth,
            significantQuakes: earthquakes.filter { $0.isSignificant },
            propheticallyRelevant: earthquakes.filter { $0.isPropheticallyRelevant }
        )
    }

    struct EarthquakeFrequency {
        let total: Int
        let byMagnitude: [Int: Int]
        let diverseLocations: Int
        let averagePerMonth: Float
        let significantQuakes: [Earthquake]
        let propheticallyRelevant: [Earthquake]

        var diversityScore: Float {
            // Higher score for more diverse locations
            Float(diverseLocations) / Float(max(total, 1)) * 100
        }

        var accelerationScore: Float {
            // Compare to historical average (rough estimate)
            let historicalMonthlyAverage: Float = 50.0 // Historical average for M4.5+
            return (averagePerMonth / historicalMonthlyAverage) * 100
        }
    }

    func monitorForCriticalEarthquakes() async {
        // Check every hour for major earthquakes
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task {
                do {
                    let recentQuakes = try await self.fetchRecentEarthquakes(minMagnitude: 6.5, days: 1)

                    for quake in recentQuakes {
                        if quake.isMajor {
                            NotificationManager.shared.sendCriticalAlert(
                                title: "Major Earthquake Alert",
                                body: "M\(quake.magnitude) earthquake near \(quake.location) - Prophetic significance being analyzed"
                            )
                        }

                        if quake.isPropheticallyRelevant {
                            NotificationManager.shared.sendCriticalAlert(
                                title: "Prophetically Significant Earthquake",
                                body: "M\(quake.magnitude) in \(quake.location) - Near biblical region"
                            )
                        }
                    }
                } catch {
                    print("Earthquake monitoring error: \(error)")
                }
            }
        }
    }
}