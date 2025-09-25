import Foundation

class OpenAIClient {
    private let baseURL = "https://api.openai.com/v1"
    private var apiKey: String? {
        KeychainManager.shared.retrieve(for: .openAIKey)
    }

    struct ChatCompletionRequest: Codable {
        let model: String
        let messages: [Message]
        let temperature: Float
        let maxTokens: Int
        let responseFormat: ResponseFormat?

        enum CodingKeys: String, CodingKey {
            case model, messages, temperature
            case maxTokens = "max_tokens"
            case responseFormat = "response_format"
        }

        struct Message: Codable {
            let role: String
            let content: String
        }

        struct ResponseFormat: Codable {
            let type: String
        }
    }

    struct ChatCompletionResponse: Codable {
        let choices: [Choice]
        let usage: Usage

        struct Choice: Codable {
            let message: Message
        }

        struct Message: Codable {
            let content: String
        }

        struct Usage: Codable {
            let totalTokens: Int

            enum CodingKeys: String, CodingKey {
                case totalTokens = "total_tokens"
            }
        }
    }

    func analyzeArticle(_ article: NewsArticle, against condition: RaptureCondition) async throws -> ProphecyAnalysisResult? {
        guard let apiKey = apiKey else {
            throw APIError.missingAPIKey
        }

        let prompt = createAnalysisPrompt(article: article, condition: condition)

        let requestBody = ChatCompletionRequest(
            model: "gpt-4-turbo-preview",
            messages: [
                ChatCompletionRequest.Message(role: "system", content: "You are a biblical prophecy analyst. Analyze news articles for relevance to specific prophecies. Return only valid JSON."),
                ChatCompletionRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.3,
            maxTokens: 500,
            responseFormat: ChatCompletionRequest.ResponseFormat(type: "json_object")
        )

        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = completionResponse.choices.first?.message.content else {
            throw APIError.noContent
        }

        // Parse JSON response
        guard let jsonData = content.data(using: .utf8),
              let result = try? JSONDecoder().decode(ProphecyAnalysisResult.self, from: jsonData) else {
            throw APIError.invalidJSON
        }

        return result
    }

    private func createAnalysisPrompt(article: NewsArticle, condition: RaptureCondition) -> String {
        return """
        Analyze this news article for relevance to the biblical prophecy.

        PROPHECY: \(condition.scriptureReference) - "\(condition.scriptureQuote)"

        ARTICLE:
        Title: \(article.title)
        Content: \(article.description)
        \(article.content?.prefix(500) ?? "")

        Consider:
        - Geographic regions mentioned
        - Key figures or nations involved
        - Specific events matching prophecy elements
        - Timeline and progression indicators

        Return JSON with these exact fields:
        {
            "relevanceScore": 0.0-1.0 (how closely this matches the prophecy),
            "confidence": 0.0-1.0 (certainty of the match),
            "keyIndicators": ["specific phrases or facts that match"],
            "prophecyAdvancement": true/false (does this move prophecy forward),
            "temporalProximity": "precursor|fulfillment|aftermath",
            "summary": "one sentence explanation"
        }
        """
    }

    func batchAnalyzeArticles(_ articles: [NewsArticle], against conditions: [RaptureCondition]) async throws -> [ProphecyAnalysisResult] {
        guard let apiKey = apiKey else {
            throw APIError.missingAPIKey
        }

        var results: [ProphecyAnalysisResult] = []

        // Batch up to 5 articles per API call for efficiency
        let articleBatches = articles.chunked(into: 5)

        for batch in articleBatches {
            let batchPrompt = createBatchAnalysisPrompt(articles: batch, conditions: conditions)

            let requestBody = ChatCompletionRequest(
                model: "gpt-4-turbo-preview",
                messages: [
                    ChatCompletionRequest.Message(role: "system", content: "Analyze multiple news articles for biblical prophecy relevance. Return a JSON array."),
                    ChatCompletionRequest.Message(role: "user", content: batchPrompt)
                ],
                temperature: 0.3,
                maxTokens: 2000,
                responseFormat: ChatCompletionRequest.ResponseFormat(type: "json_object")
            )

            guard let url = URL(string: "\(baseURL)/chat/completions") else { continue }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(requestBody)

            let (data, _) = try await URLSession.shared.data(for: request)
            let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)

            if let content = completionResponse.choices.first?.message.content,
               let jsonData = content.data(using: .utf8) {
                // Parse batch results
                if let batchResults = try? JSONDecoder().decode([ProphecyAnalysisResult].self, from: jsonData) {
                    results.append(contentsOf: batchResults)
                }
            }

            // Rate limiting
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }

        return results
    }

    private func createBatchAnalysisPrompt(articles: [NewsArticle], conditions: [RaptureCondition]) -> String {
        let articlesText = articles.enumerated().map { index, article in
            "Article \(index + 1): \(article.title) - \(article.description)"
        }.joined(separator: "\n\n")

        let conditionsText = conditions.map { condition in
            "\(condition.scriptureReference): \(condition.scriptureQuote)"
        }.joined(separator: "\n")

        return """
        Analyze these \(articles.count) news articles against biblical prophecies.
        Return a JSON array with one analysis per article that scores > 0.5 relevance.

        PROPHECIES TO CHECK:
        \(conditionsText)

        ARTICLES:
        \(articlesText)

        Return JSON array format:
        [
            {
                "relevanceScore": 0.0-1.0,
                "confidence": 0.0-1.0,
                "keyIndicators": [],
                "prophecyAdvancement": boolean,
                "temporalProximity": "string",
                "summary": "string"
            }
        ]
        """
    }
}

enum APIError: Error {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case noContent
    case invalidJSON
}