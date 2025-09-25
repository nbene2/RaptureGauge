import Foundation

class NewsAPIClient {
    private let baseURL = "https://newsapi.org/v2"
    private var apiKey: String? {
        KeychainManager.shared.retrieve(for: .newsAPIKey)
    }

    struct NewsAPIResponse: Codable {
        let status: String
        let totalResults: Int
        let articles: [Article]

        struct Article: Codable {
            let source: Source
            let author: String?
            let title: String
            let description: String?
            let url: String
            let urlToImage: String?
            let publishedAt: String
            let content: String?

            struct Source: Codable {
                let id: String?
                let name: String
            }
        }
    }

    func fetchNews(query: String, pageSize: Int = 20) async throws -> [NewsArticle] {
        guard let apiKey = apiKey else {
            throw APIError.missingAPIKey
        }

        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/everything?q=\(queryEncoded)&pageSize=\(pageSize)&sortBy=relevancy&apiKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        let newsResponse = try decoder.decode(NewsAPIResponse.self, from: data)

        return newsResponse.articles.compactMap { article in
            guard let publishedDate = ISO8601DateFormatter().date(from: article.publishedAt) else {
                return nil
            }

            return NewsArticle(
                title: article.title,
                description: article.description ?? "",
                content: article.content,
                url: article.url,
                publishedAt: publishedDate,
                source: article.source.name
            )
        }
    }

    func fetchIsraelNews() async throws -> [NewsArticle] {
        let queries = [
            "Israel Jerusalem",
            "Temple Mount",
            "Israeli government",
            "IDF military",
            "West Bank settlement"
        ]

        var allArticles: [NewsArticle] = []
        for query in queries {
            let articles = try await fetchNews(query: query, pageSize: 10)
            allArticles.append(contentsOf: articles)
        }

        return Array(Set(allArticles))
    }

    func fetchProphecyRelatedNews() async throws -> [NewsArticle] {
        let queries = [
            "digital currency CBDC",
            "cashless society",
            "biometric payment",
            "Russia Iran Turkey",
            "Christian persecution",
            "earthquake magnitude",
            "global government UN",
            "peace treaty Middle East",
            "artificial intelligence sentient"
        ]

        var allArticles: [NewsArticle] = []
        for query in queries {
            do {
                let articles = try await fetchNews(query: query, pageSize: 5)
                allArticles.append(contentsOf: articles)
                // Rate limiting
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            } catch {
                print("Error fetching news for \(query): \(error)")
            }
        }

        return Array(Set(allArticles))
    }
}

// Make NewsArticle conform to Hashable for Set operations
extension NewsArticle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    static func == (lhs: NewsArticle, rhs: NewsArticle) -> Bool {
        return lhs.url == rhs.url
    }
}