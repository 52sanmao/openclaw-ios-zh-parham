# OpenClaw

A native iOS dashboard app for monitoring and managing the OpenClaw API gateway at `api.appwebdev.co.uk`. Built with SwiftUI, Swift Concurrency, and the Observation framework — zero third-party dependencies.

## Features

- **System Health** — Real-time CPU, RAM, and disk usage with animated ring gauges and color-coded thresholds
- **Cron Jobs** — Live status of scheduled jobs with next-run countdowns and pass/fail indicators
- **Outreach Metrics** — Lead counts, channel breakdowns (email, WhatsApp), reply rates, and conversions
- **Blog Pipeline** — Published article count, active pipeline stages (queued, researching, writing, images, publishing), and link to latest post
- **Settings** — Token management, connection diagnostics, and gateway info
- **Pull-to-Refresh** — All four dashboard cards refresh concurrently

## Architecture

```
OpenClaw/
├── Core/                           # Networking, security, base classes
│   ├── GatewayClient.swift         # HTTP client + GatewayClientProtocol
│   ├── GatewayModels.swift         # DTOs, request/response types, errors
│   ├── KeychainService.swift       # Secure token storage (iOS Keychain)
│   └── LoadableViewModel.swift     # Generic async-loading ViewModel base
│
├── Features/                       # Feature modules (MVVM per feature)
│   ├── Auth/
│   │   └── TokenSetupView.swift    # Bearer token onboarding
│   ├── Home/
│   │   ├── HomeView.swift          # Dashboard container with pull-to-refresh
│   │   ├── System/                 # System health (VM + Model + Card)
│   │   ├── Cron/                   # Cron jobs (VM + Model + Card)
│   │   ├── Outreach/               # Outreach stats (VM + Model + Card)
│   │   └── Blog/                   # Blog pipeline (VM + Model + Card)
│   └── Settings/
│       └── SettingsView.swift      # Token config + connection test
│
├── Shared/                         # Reusable UI components
│   ├── DesignSystem/               # Foundation design tokens
│   │   ├── Spacing.swift           # 4-pt grid spacing scale
│   │   ├── AppColors.swift         # Semantic color palette
│   │   ├── AppTypography.swift     # Type styles (Dynamic Type)
│   │   └── AppRadius.swift         # Corner radius tokens
│   ├── CardContainer.swift         # Card shell with header + loading/stale states
│   ├── RingGauge.swift             # Circular percentage gauge
│   └── LoadingErrorViews.swift     # Shared loading/error placeholders
│
├── OpenClawApp.swift               # @main entry point
└── ContentView.swift               # Auth router (token check → Home or Setup)
```

### Patterns

| Layer | Pattern | Details |
|-------|---------|---------|
| UI | SwiftUI + MVVM | Declarative views observe `@Observable` ViewModels |
| State | `LoadableViewModel<T>` | Generic base handles loading, error, staleness, and cancellation |
| Networking | `GatewayClientProtocol` | Protocol-based DI — concrete `GatewayClient` uses `URLSession` + `async/await` |
| Security | `KeychainService` | Bearer tokens stored in iOS Keychain, never in UserDefaults |
| Concurrency | Swift Concurrency | `@MainActor` ViewModels, structured `Task` management, concurrent refresh |
| Design System | Semantic tokens | `Spacing`, `AppColors`, `AppTypography`, `AppRadius` — no magic numbers in views |

### Data Flow

```
View (.task / .refreshable)
  → LoadableViewModel (start / refresh)
    → GatewayClientProtocol (stats / invoke)
      → URLSession async/await
        → api.appwebdev.co.uk
```

## Requirements

- iOS 17.0+
- Xcode 16+
- Swift 6
- No external dependencies

## Getting Started

1. Clone the repo and open `OpenClaw.xcodeproj` in Xcode
2. Build and run on a simulator or device (iOS 17+)
3. On first launch, paste your gateway Bearer token
4. The dashboard loads automatically — pull down to refresh

## API Endpoints

| Method | Path | Used By |
|--------|------|---------|
| GET | `/stats/system` | System Health card |
| GET | `/stats/outreach` | Outreach Stats card |
| GET | `/stats/blog` | Blog Pipeline card |
| POST | `/tools/invoke` | Cron Jobs card (`{"tool":"cron","args":{"action":"list"}}`) |

All requests require `Authorization: Bearer <token>` header.

## License

Private — all rights reserved.
