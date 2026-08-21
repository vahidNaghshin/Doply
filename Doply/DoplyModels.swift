import SwiftUI
import Combine

// MARK: - Shop

enum ShopCategory: String, CaseIterable, Identifiable {
    case all, seeds, plants, deco, animals, land, rare
    var id: String { rawValue }

    var label: String {
        switch self {
        case .all:     return "✨ All"
        case .seeds:   return "🌱 Seeds"
        case .plants:  return "🌳 Plants"
        case .deco:    return "🏡 Decorations"
        case .animals: return "🐝 Animals"
        case .land:    return "🗺️ Land"
        case .rare:    return "⭐ Rare"
        }
    }
}

struct ShopItem: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    let price: Int
    let category: ShopCategory
    let toast: String
    var isRare: Bool { category == .rare }
}

// MARK: - Quests

struct Quest: Identifiable {
    let id = UUID()
    let name: String
    let progressText: String
    let progress: Double
    let reward: String
    var style: ProgressTrack.Style = .green
    var isDone: Bool = false
    var showsTrack: Bool = true
    var dimmed: Bool = false
}

// MARK: - Social

struct Friend: Identifiable {
    let id = UUID()
    let avatar: String
    let name: String
    let stepsToday: Int
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let medal: String
    let name: String
    let steps: Int
}

// MARK: - Profile

struct StatChipData: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

struct Achievement: Identifiable {
    let id = UUID()
    let emoji: String
    let unlocked: Bool
}

// MARK: - App State

@MainActor
final class DoplyStore: ObservableObject {
    // Balances
    @Published var coins: Int = 1_240
    @Published var water: Int = 84

    // Activity
    @Published var steps: Int = 4_823
    @Published var stepGoal: Int = 6_000
    @Published var streak: Int = 7
    @Published var bestStreak: Int = 21

    // Profile
    @Published var userName = "Alex"
    @Published var level = 12
    @Published var xp: Double = 0.82

    var stepProgress: Double { min(1, Double(steps) / Double(stepGoal)) }
    var stepsRemaining: Int { max(0, stepGoal - steps) }
    var stepPercent: Int { Int((stepProgress * 100).rounded()) }

    // MARK: Content

    let shopItems: [ShopItem] = [
        .init(emoji: "🌸", name: "Cherry Blossom Tree", price: 120,  category: .plants,  toast: "Cherry Blossom Tree added! 🌸"),
        .init(emoji: "🌻", name: "Sunflower Seed",      price: 30,   category: .seeds,   toast: "Sunflower Seed planted! 🌻"),
        .init(emoji: "🏮", name: "Garden Lantern",      price: 65,   category: .deco,    toast: "Garden Lantern added! 🏮"),
        .init(emoji: "🐇", name: "Garden Bunny",        price: 180,  category: .animals, toast: "A bunny hopped in! 🐇"),
        .init(emoji: "🗺️", name: "Meadow Expansion",    price: 500,  category: .land,    toast: "Meadow unlocked! 🗺️"),
        .init(emoji: "🦄", name: "Rainbow Sprite",      price: 1200, category: .rare,    toast: "A Rainbow Sprite appeared! 🦄"),
        .init(emoji: "🌵", name: "Desert Cactus",       price: 45,   category: .plants,  toast: "Desert Cactus added! 🌵"),
        .init(emoji: "⛲", name: "Stone Fountain",      price: 220,  category: .deco,    toast: "Stone Fountain added! ⛲")
    ]

    let dailyQuests: [Quest] = [
        .init(name: "🚶 Walk 6,000 steps", progressText: "4,823 / 6,000",
              progress: 0.80, reward: "+60 🪙  +15 💧"),
        .init(name: "🚴 Cycle 5 km", progressText: "2.1 / 5 km",
              progress: 0.42, reward: "+40 🪙  +10 💧"),
        .init(name: "💧 Water your garden", progressText: "Done ✓",
              progress: 1.0, reward: "+20 🪙", isDone: true)
    ]

    let weeklyQuests: [Quest] = [
        .init(name: "🌟 Walk 40,000 steps", progressText: "27,340 / 40,000",
              progress: 0.68, reward: "+300 🪙  +80 💧  Rare Seed Pack 🎁",
              style: .gold)
    ]

    let upcomingQuests: [Quest] = [
        .init(name: "🦋 Weekend Butterfly Event", progressText: "Starts Sat",
              progress: 0, reward: "Limited-time decorations",
              showsTrack: false, dimmed: true)
    ]

    let friends: [Friend] = [
        .init(avatar: "🧑‍🦱", name: "Sam",    stepsToday: 6_204),
        .init(avatar: "👩‍🦰", name: "Mia",    stepsToday: 5_110),
        .init(avatar: "🧔",   name: "Jordan", stepsToday: 2_988)
    ]

    let leaderboard: [LeaderboardEntry] = [
        .init(medal: "🥇", name: "Alex (you)", steps: 42_381),
        .init(medal: "🥈", name: "Sam",        steps: 38_204),
        .init(medal: "🥉", name: "Mia",        steps: 31_928),
        .init(medal: "4",  name: "Jordan",     steps: 24_650)
    ]

    let stats: [StatChipData] = [
        .init(value: "42,381", label: "Steps this week"),
        .init(value: "7",      label: "Day streak 🔥"),
        .init(value: "12",     label: "Achievements"),
        .init(value: "318",    label: "Total activities")
    ]

    let achievements: [Achievement] = [
        .init(emoji: "🌳", unlocked: true),
        .init(emoji: "🔥", unlocked: true),
        .init(emoji: "🦋", unlocked: true),
        .init(emoji: "🌸", unlocked: true),
        .init(emoji: "🐝", unlocked: true),
        .init(emoji: "💧", unlocked: true),
        .init(emoji: "🦄", unlocked: false),
        .init(emoji: "🏰", unlocked: false)
    ]
}

// MARK: - Formatting

extension Int {
    var grouped: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
