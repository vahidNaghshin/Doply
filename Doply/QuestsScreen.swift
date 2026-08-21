import SwiftUI

struct QuestsScreen: View {
    @EnvironmentObject private var store: DoplyStore

    var body: some View {
        ScreenScroll {
            SectionTitle(text: "🎯 Quests", topPadding: 0)

            StreakBanner(current: store.streak, best: store.bestStreak)
                .padding(.bottom, 18)

            SectionTitle(text: "Daily Quests", topPadding: 0)
            ForEach(store.dailyQuests) { QuestCard(quest: $0) }

            SectionTitle(text: "Weekly Challenge")
            ForEach(store.weeklyQuests) { QuestCard(quest: $0) }

            SectionTitle(text: "Upcoming")
            ForEach(store.upcomingQuests) { QuestCard(quest: $0) }
        }
        .background(DoplyColor.cream)
    }
}

private struct StreakBanner: View {
    let current: Int
    let best: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Current streak")
                    .font(DoplyFont.body(12, .bold))
                    .foregroundStyle(DoplyColor.streakLbl)
                Text("🔥 \(current) days")
                    .font(DoplyFont.display(26, .black))
                    .foregroundStyle(DoplyColor.streakNum)
            }
            Spacer()
            Text("Best: \(best)")
                .font(DoplyFont.body(12, .bold))
                .foregroundStyle(DoplyColor.streakLbl)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.55), in: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            LinearGradient(colors: [DoplyColor.streakA, DoplyColor.yellowSoft],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous)
        )
        .shadowSm()
    }
}

struct QuestCard: View {
    let quest: Quest

    var body: some View {
        DoplyCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(quest.name)
                        .font(DoplyFont.body(14.5, .bold))
                        .foregroundStyle(DoplyColor.ink)
                        .strikethrough(quest.isDone)
                    Spacer()
                    Text(quest.progressText)
                        .font(DoplyFont.body(12.5, .semibold))
                        .foregroundStyle(DoplyColor.inkSoft)
                }

                if quest.showsTrack {
                    ProgressTrack(value: quest.progress, style: quest.style)
                }

                Text(quest.reward)
                    .font(DoplyFont.body(12.5, .bold))
                    .foregroundStyle(DoplyColor.coin)
            }
        }
        .opacity(quest.isDone ? 0.55 : (quest.dimmed ? 0.7 : 1))
        .padding(.bottom, 12)
    }
}

#Preview {
    QuestsScreen()
        .environmentObject(DoplyStore())
        .environmentObject(ToastCenter())
}
