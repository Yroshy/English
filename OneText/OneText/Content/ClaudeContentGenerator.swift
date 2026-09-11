import Foundation

/// Calls the Anthropic API directly (no SDK dependency) to generate fresh,
/// real-world routine texts and study material, calibrated to a CEFR level,
/// following Vânia Sausen's "one text, seven days" methodology:
/// https://www.youtube.com/results?search_query=vania+sausen+um+unico+texto
final class ClaudeContentGenerator: ContentGenerating {

    /// Pinned to a specific dated snapshot for reproducibility; bump when you
    /// want the app to pick up a newer model.
    private let model = "claude-sonnet-5"
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    private func apiKey() throws -> String {
        guard let key = APIKeyStore.load(), !key.isEmpty else {
            throw ContentError.missingAPIKey
        }
        return key
    }

    // MARK: - Weekly text generation

    func generateWeeklyText(level: CEFRLevel, topic: RoutineTopic, avoiding usedTitles: [String]) async throws -> WeeklyText {
        let avoidClause = usedTitles.isEmpty ? "" :
            "Do not reuse any of these previous titles: \(usedTitles.joined(separator: ", ")).\n"

        let prompt = """
        You are creating study material for a Brazilian learner of English, following this \
        exact weekly method: one short text is explored for 7 days (Monday: reading/chunks, \
        Tuesday: collocations, Wednesday: listening/shadowing, Thursday: grammar, Friday: \
        writing, Saturday: speaking, Sunday: review).

        Write ONE short text about the everyday routine topic "\(topic.displayName)" \
        (topic id: \(topic.rawValue)), calibrated EXACTLY to CEFR level \(level.displayName) \
        (\(level.title)). The text must:
        - Use real, everyday, natural English (no invented or literary vocabulary).
        - Be about \(level.wordCountRange.lowerBound)-\(level.wordCountRange.upperBound) words.
        - Have a bit of narrative detail (not just a bare list of actions) appropriate for the level.
        - Be grammatically calibrated to \(level.displayName): \(level.description)
        \(avoidClause)
        Respond with ONLY valid JSON (no markdown fences, no commentary) matching exactly this shape:
        {
          "level": "\(level.rawValue)",
          "topic": "\(topic.rawValue)",
          "title": "string, short and natural",
          "body": "the text itself, in English",
          "comprehensionQuestions": [
            {"question": "string in English", "answerHint": "short answer in English"}
          ],
          "keyChunks": [
            {"expression": "a multi-word chunk/expression from the text (never a single isolated word)",
             "meaningPT": "meaning in Brazilian Portuguese",
             "exampleFromText": "the sentence from the text containing it",
             "collocations": ["3 collocations using this chunk"],
             "usageExample": "a NEW sentence, different from exampleFromText, that applies one of the collocations to a different everyday situation (this is the 'contexto de aplicação' that reinforces the expression)"}
          ],
          "grammarPoints": [
            {"title": "short PT title of the grammar point",
             "explanationPT": "simple explanation in Portuguese, referencing the text",
             "exampleFromText": "sentence from the text illustrating it"}
          ],
          "writingPrompt": "instruction in Portuguese asking the learner to write 5-10 sentences adapting the topic to their own life",
          "speakingPrompt": "instruction in Portuguese for reading aloud and later speaking freely about the topic"
        }
        Provide exactly 3 comprehensionQuestions, exactly 5 keyChunks (each with exactly 3 collocations), \
        and 2-3 grammarPoints appropriate for \(level.displayName).
        """

        let json = try await complete(prompt: prompt, maxTokens: 3000)
        guard let data = json.data(using: .utf8) else { throw ContentError.invalidResponse }
        do {
            var text = try JSONDecoder().decode(WeeklyText.self, from: data)
            text.id = UUID()
            text.createdAt = Date()
            return text
        } catch {
            throw ContentError.invalidResponse
        }
    }

    // MARK: - Collocations refresh (Tuesday "gerar mais" button)

    func generateCollocations(for expression: String, level: CEFRLevel) async throws -> [String] {
        let prompt = """
        Give 3 natural English collocations (word combinations) using the expression \
        "\(expression)", suitable for a CEFR \(level.displayName) English learner. \
        Respond with ONLY valid JSON: {"collocations": ["...", "...", "..."]}
        """
        let json = try await complete(prompt: prompt, maxTokens: 300)
        guard let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data),
              let list = decoded["collocations"] else {
            throw ContentError.invalidResponse
        }
        return list
    }

    // MARK: - Writing feedback (Friday)

    func generateWritingFeedback(userText: String, originalText: String, level: CEFRLevel) async throws -> WritingFeedback {
        let prompt = """
        A CEFR \(level.displayName) Brazilian English learner adapted the following text to their \
        own life:

        ORIGINAL TEXT:
        \(originalText)

        LEARNER'S TEXT:
        \(userText)

        Correct the learner's text minimally (fix real errors only, keep their voice and level), \
        and explain briefly, in Portuguese, WHY each meaningful correction was made (grammar, word \
        choice, collocation, etc). Respond with ONLY valid JSON:
        {"correctedText": "the corrected English text", "notesPT": ["short PT explanation 1", "short PT explanation 2"]}
        """
        let json = try await complete(prompt: prompt, maxTokens: 1200)
        guard let data = json.data(using: .utf8),
              let feedback = try? JSONDecoder().decode(WritingFeedback.self, from: data) else {
            throw ContentError.invalidResponse
        }
        return feedback
    }

    // MARK: - Low-level API call

    private func complete(prompt: String, maxTokens: Int) async throws -> String {
        let key = try apiKey()
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ContentError.network(error)
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ContentError.invalidResponse
        }

        struct AnthropicResponse: Decodable {
            struct Block: Decodable { let type: String; let text: String? }
            let content: [Block]
        }

        guard let decoded = try? JSONDecoder().decode(AnthropicResponse.self, from: data),
              let text = decoded.content.first(where: { $0.type == "text" })?.text else {
            throw ContentError.invalidResponse
        }

        return Self.stripMarkdownFences(from: text)
    }

    private static func stripMarkdownFences(from text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```") {
            result = result.components(separatedBy: "\n").dropFirst().joined(separator: "\n")
            if result.hasSuffix("```") {
                result = String(result.dropLast(3))
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
