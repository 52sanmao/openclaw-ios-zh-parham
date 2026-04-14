import Foundation
import ObjectiveC.runtime

private final class ParhamOpenClawChineseBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let translated = parhamOpenClawChineseTranslations[key] {
            return translated
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

private let parhamOpenClawChineseTranslations: [String: String] = [
    "Connect to Gateway": "连接到网关",
    "Add Account": "添加账户",
    "Enter your gateway URL and Bearer token.": "请输入网关地址和 Bearer Token。",
    "NAME": "名称",
    "GATEWAY URL": "网关地址",
    "BEARER TOKEN": "Bearer Token",
    "AGENT ID": "智能体 ID",
    "WORKSPACE PATH": "工作区路径",
    "Connect": "连接",
    "Send a message to your agent.": "向您的智能体发送消息。",
    "Thinking…": "思考中…",
    "Streaming": "流式输出中",
    "Purpose": "用途",
    "Investigate with AI": "用 AI 排查",
    "Load More": "加载更多",
    "Run History": "运行历史",
    "Error Investigation": "错误排查",
    "Investigated %@": "已排查 %@",
    "Execution Trace": "执行追踪",
    "No session data available.": "暂无会话数据。",
    "Submit": "提交",
    "Published": "已发布",
    "View Details": "查看详情",
    "Completed": "已完成",
    "Failed": "失败",
    "Copy": "复制",
    "Copied": "已复制",
    "Investigate": "排查",
    "Gateway": "网关",
    "works": "正常",
    "Loading…": "加载中…",
    "All systems OK": "系统正常",
    "System unavailable": "系统不可用",
    "Reply Rate": "回复率",
    "Load": "负载",
    "total tokens": "总 Token",
    "cost": "成本",
    "By Model": "按模型",
    "No workspace files found.": "未找到工作区文件。",
    "Additional features coming soon.": "更多功能即将上线。",
    "Main Session": "主会话",
    "Running": "运行中",
    "Idle": "空闲",
    "View Trace": "查看追踪",
    "Diagnostics": "诊断",
    "Active": "当前使用",
    "Active Account": "当前账户",
    "Profile": "配置档",
    "Native Tools": "原生工具",
    "Select an item": "请选择一个项目"
]

enum ChineseLocalization {
    static func install() {
        guard object_getClass(Bundle.main) != ParhamOpenClawChineseBundle.self else { return }
        object_setClass(Bundle.main, ParhamOpenClawChineseBundle.self)
    }
}
