import SwiftUI

/// Definition of a quick command button.
struct QuickCommand: Identifiable, Sendable {
    let id: String
    let name: String
    let icon: String
    let iconColor: Color
    let confirmMessage: String
    let toolName: String
    let args: [String: String]

    /// Scaffold commands — add real ones as needed.
    static let all: [QuickCommand] = [
        // Row 1 — visible by default
        QuickCommand(id: "restart-gateway", name: "Restart Gateway", icon: "arrow.clockwise.circle.fill", iconColor: AppColors.warning, confirmMessage: "Restart the OpenClaw gateway process?", toolName: "exec", args: ["command": "systemctl restart openclaw"]),
        QuickCommand(id: "clear-cache", name: "Clear Cache", icon: "trash.circle.fill", iconColor: AppColors.danger, confirmMessage: "Clear all server-side caches?", toolName: "exec", args: ["command": "openclaw cache clear"]),
        QuickCommand(id: "deploy-site", name: "Deploy Site", icon: "arrow.up.circle.fill", iconColor: AppColors.success, confirmMessage: "Trigger a production site deploy?", toolName: "exec", args: ["command": "cd /home/node/.openclaw/workspace/orchestrator/appwebdev && git pull && npm run build"]),
        // Row 2 — visible by default
        QuickCommand(id: "health-check", name: "Health Check", icon: "heart.circle.fill", iconColor: AppColors.metricPositive, confirmMessage: "Run a full health check?", toolName: "exec", args: ["command": "openclaw health"]),
        QuickCommand(id: "sync-notion", name: "Sync Notion", icon: "arrow.triangle.2.circlepath.circle.fill", iconColor: AppColors.metricSecondary, confirmMessage: "Sync data from Notion?", toolName: "exec", args: ["command": "openclaw notion sync"]),
        QuickCommand(id: "backup-db", name: "Backup DB", icon: "externaldrive.fill.badge.checkmark", iconColor: AppColors.metricPrimary, confirmMessage: "Create a database backup?", toolName: "exec", args: ["command": "openclaw backup create"]),
        // Row 3+ — hidden behind "Show More"
        QuickCommand(id: "tail-logs", name: "Tail Logs", icon: "doc.text.magnifyingglass", iconColor: AppColors.neutral, confirmMessage: "Fetch the latest 50 log lines?", toolName: "exec", args: ["command": "journalctl -u openclaw -n 50 --no-pager"]),
        QuickCommand(id: "disk-usage", name: "Disk Usage", icon: "internaldrive.fill", iconColor: AppColors.metricWarm, confirmMessage: "Check disk usage?", toolName: "exec", args: ["command": "df -h"]),
        QuickCommand(id: "memory-usage", name: "Memory Info", icon: "memorychip.fill", iconColor: AppColors.metricTertiary, confirmMessage: "Check memory usage?", toolName: "exec", args: ["command": "free -h"]),
        QuickCommand(id: "uptime", name: "Uptime", icon: "clock.fill", iconColor: AppColors.success, confirmMessage: "Check server uptime?", toolName: "exec", args: ["command": "uptime"]),
        QuickCommand(id: "nginx-status", name: "Nginx Status", icon: "network", iconColor: AppColors.info, confirmMessage: "Check Nginx status?", toolName: "exec", args: ["command": "systemctl status nginx --no-pager"]),
        QuickCommand(id: "ssl-check", name: "SSL Check", icon: "lock.circle.fill", iconColor: AppColors.metricPositive, confirmMessage: "Check SSL certificate status?", toolName: "exec", args: ["command": "certbot certificates 2>/dev/null || echo 'certbot not found'"]),
    ]

    static let visibleCount = 6
}
