import Foundation

/// Centralized prompt templates for agent-mediated actions.
/// Edit this file to tune prompts — all templates in one place.
enum PromptTemplates {

    /// Context lines to include before/after the target section for safety.
    private static let contextPadding = 2

    /// Build a prompt for editing a memory file based on user comments.
    static func editMemoryFile(
        path: String,
        fullText: String,
        comments: [MemoryComment]
    ) -> (system: String, user: String) {

        let system = """
        You have a task: update a workspace markdown file based on user comments.
        The workspace root is: ~/.openclaw/workspace/orchestrator/

        Steps:
        1. Read the file at the given path using the read tool
        2. Apply each comment to the specified line range
        3. Save the result using the write tool to the same path
        4. Reply with a 2-3 bullet summary of changes

        Rules:
        - Only change lines mentioned in comments — preserve everything else
        - Maintain markdown formatting and structure
        - You MUST read then write the file — do not just output content
        """

        let lines = fullText.components(separatedBy: "\n")
        var commentBlocks: [String] = []

        for (index, comment) in comments.enumerated() {
            let safeStart = max(0, comment.lineStart - contextPadding)
            let safeEnd = min(lines.count - 1, comment.lineEnd + contextPadding)
            let contextLines = lines[safeStart...safeEnd].joined(separator: "\n")

            let lineLabel = comment.lineStart == comment.lineEnd
                ? "line \(comment.lineStart + 1)"
                : "lines \(comment.lineStart + 1)-\(comment.lineEnd + 1)"

            commentBlocks.append("""
            [\(index + 1)] \(lineLabel):
            ```
            \(contextLines)
            ```
            Change: \(comment.text)
            """)
        }

        let user = """
        File: `\(path)`
        Total lines: \(lines.count)

        \(commentBlocks.joined(separator: "\n\n"))
        """

        return (system: system, user: user)
    }

    /// Build a prompt for appending a note to today's daily log.
    static func appendDailyNote(
        date: String,
        note: String
    ) -> (system: String, user: String) {
        let system = """
        You have a task: append a note to today's daily memory log.

        Steps:
        1. Read the file at `memory/\(date).md` (may not exist yet)
        2. If empty/missing, create with heading `# Daily Log — \(date)`
        3. Add the note under an appropriate time section
        4. Save using the write tool
        5. Reply confirming what was added
        """

        let user = "Add this note:\n\(note)"

        return (system: system, user: user)
    }
}

/// Request body for /v1/chat/completions.
struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [Message]
    let stream: Bool

    struct Message: Encodable {
        let role: String
        let content: String
    }

    init(system: String, user: String, model: String = "openclaw", stream: Bool = false) {
        self.model = model
        self.stream = stream
        self.messages = [
            Message(role: "system", content: system),
            Message(role: "user", content: user)
        ]
    }
}

/// Response from /v1/chat/completions (non-streaming).
struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
    }

    var text: String? {
        choices.first?.message.content
    }
}
