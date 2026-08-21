# 🌱 Doply

Doply is a playful, gamified step-tracking iOS app built entirely in **SwiftUI**. Walk, earn coins and water, and grow your own little garden — complete quests, compete with friends, and unlock rare decorations along the way.

<p align="left">
  <em>Home · Quests · Shop · Friends · Profile</em>
</p>

## ✨ Features

- **Home** — An animated garden hero, a live progress ring for today's steps, quick rewards preview, and an upcoming mission card.
- **Walk Session** — Tap *Start Moving* to launch a full-screen live walk session powered by `CMPedometer` (Core Motion), tracking real-time steps, distance, and elapsed time. Finishing a walk instantly credits steps and coins back to Home — no relaunch needed.
- **Quests** — Daily, weekly, and upcoming quests with progress tracking and coin/water rewards.
- **Shop** — Spend Doply Coins on seeds, plants, decorations, animals, land expansions, and rare items for your garden.
- **Friends** — See friends' daily step counts and a weekly leaderboard.
- **Profile** — Stats, achievements, and level/XP progress.

## 🧱 Tech Stack

- **SwiftUI** for the entire UI layer
- **Combine / `ObservableObject`** for shared, reactive app state
- **Core Motion (`CMPedometer`)** for live step counting and distance during a walk session, with a simulator-safe fallback that fakes step increments so the flow is testable without a physical device
- No third-party dependencies — pure Swift Package-free Xcode project

## 📂 Project Structure

```
Doply/
├── DoplyApp.swift          # App entry point, RootView, tab navigation
├── DoplyModels.swift       # DoplyStore (shared app state) + data models
├── DoplyTheme.swift        # Design tokens: colors, fonts, cards, toasts
├── HomeScreen.swift        # Home tab: garden hero, progress, Start Moving CTA
├── WalkSessionManager.swift# Live walk tracking (CMPedometer) + reward formula
├── WalkSessionView.swift   # Full-screen live walk session UI
├── QuestsScreen.swift      # Daily/weekly/upcoming quests
├── ShopScreen.swift        # In-app garden shop
├── FriendsScreen.swift     # Friends activity + leaderboard
├── ProfileScreen.swift     # Profile stats & achievements
└── Assets.xcassets/        # App icon, accent color, images
```

## 🚀 Getting Started

### Requirements

- Xcode 26 or later
- iOS 17.6+ deployment target
- Swift 5

### Build & Run

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd Doply
   ```
2. Open `Doply.xcodeproj` in Xcode.
3. Select a simulator or device and press **Run** (⌘R).

Or build from the command line:

```bash
xcodebuild -scheme Doply -configuration Debug \
  -destination 'generic/platform=iOS Simulator' build
```

### Motion & Fitness Permission

Live step counting during a Walk Session uses Core Motion, which requires the `NSMotionUsageDescription` permission (already configured in the project's build settings). On a physical device you'll be prompted to allow Motion & Fitness access; on the iOS Simulator, steps are simulated automatically since `CMPedometer` has no real data source there.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
