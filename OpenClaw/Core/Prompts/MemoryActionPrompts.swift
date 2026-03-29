import Foundation

/// Prompt templates for memory maintenance actions.
extension PromptTemplates {

    /// Full memory cleanup — read docs, update today, then clean all files.
    static func memoryFullCleanup() -> (system: String, user: String) {
        let system = """
        You have a task: perform a full memory cleanup.

        Follow these steps IN ORDER:
        1. Read the memory best practices documentation at /app/docs — understand the rules for how memory files should be structured, what to keep, and what to remove
        2. Read today's session work to understand what happened today
        3. Update today's daily memory log based on today's work
        4. Read ALL memory files (COMMANDS.md, SOUL.md, USER.md, TOOLS.md, MEMORY.md files, memory folder with all daily logs, reference files)
        5. Clean up and reorganise all memory files based on the best practices you read in step 1
        6. Reply with a summary of what you updated and cleaned

        Rules:
        - Always read docs first — never clean without understanding best practices
        - Always check the statement you are changing against the actual code we have — if it doesn't follow best practices, update it
        - Update today's memory BEFORE cleaning older files
        - Remove stale or redundant entries across all files
        - Consolidate duplicate information
        - Maintain the existing file structure and naming conventions
        - Use the write tool to save changes
        """
        let user = "Perform a full memory cleanup. Read docs first, update today, then clean all files."
        return (system: system, user: user)
    }

    /// Today-only memory cleanup — read docs, update today's memory.
    static func memoryTodayCleanup() -> (system: String, user: String) {
        let system = """
        You have a task: clean up today's memory.

        Follow these steps IN ORDER:
        1. Read the memory best practices documentation at /app/docs — understand the rules
        2. Read the main memory files (MEMORY.md, SOUL.md and today's memory if there is one) to understand the full context
        3. Read today's session work to understand what happened today
        4. Update today's daily memory log — add missing items, remove stale entries, improve clarity
        5. If today's work affects any main memory files, update those too
        6. Reply with a summary of what you updated

        Rules:
        - Always read docs first
        - Always check the statement you are changing against the actual code we have.
        - Focus on today only — don't touch older daily logs
        - Ensure today's log accurately reflects what was done
        - Use the write tool to save changes
        """
        let user = "Clean up today's memory. Read docs first, then update today's log and any affected main files."
        return (system: system, user: user)
    }
}
