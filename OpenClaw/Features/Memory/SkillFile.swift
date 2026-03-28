import Foundation

/// A skill folder entry from the skills-list command.
struct SkillFile: Identifiable, Sendable {
    let id: String
    let name: String

    /// Display name: "blog-researcher" → "Blog Researcher", "skill-reddit" → "Reddit"
    var displayName: String {
        name.replacingOccurrences(of: "skill-", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }

    /// Parse skills-list stdout into skill entries.
    /// Filters out non-skill entries (files with extensions).
    static func parse(stdout: String) -> [SkillFile] {
        stdout
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(String.init)
            .filter { !$0.contains(".") && !$0.isEmpty }
            .map { SkillFile(id: $0, name: $0) }
            .sorted { $0.displayName < $1.displayName }
    }
}

/// A file inside a skill folder.
struct SkillFileEntry: Identifiable, Sendable {
    let id: String          // relative path within skill folder, e.g. "scripts/engage.py"
    let skillId: String     // parent skill folder name

    var name: String { (id as NSString).lastPathComponent }
    var isMarkdown: Bool { id.hasSuffix(".md") }

    /// Path for `memory_get` — relative to workspace root.
    var absolutePath: String { "skills/\(skillId)/\(id)" }

    /// Parse skill-files stdout into entries.
    static func parse(stdout: String, skillId: String) -> [SkillFileEntry] {
        stdout
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { SkillFileEntry(id: String($0), skillId: skillId) }
    }
}
