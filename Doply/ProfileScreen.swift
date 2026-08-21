import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var toast: ToastCenter

    private let statColumns = [GridItem(.flexible(), spacing: 10),
                               GridItem(.flexible(), spacing: 10)]

    private let achvColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        ScreenScroll {
            ProfileHeader()
                .padding(.bottom, 20)

            LazyVGrid(columns: statColumns, spacing: 10) {
                ForEach(store.stats) { StatChip(data: $0) }
            }
            .padding(.bottom, 18)

            SectionTitle(text: "🏅 Achievements & Collection", topPadding: 0)

            LazyVGrid(columns: achvColumns, spacing: 8) {
                ForEach(store.achievements) { AchievementCard(achievement: $0) }
            }

            SettingsLink {
                toast.show("Settings coming soon ⚙️")
            }
            .padding(.top, 20)
        }
        .background(DoplyColor.cream)
    }
}

// MARK: - Header

private struct ProfileHeader: View {
    @EnvironmentObject private var store: DoplyStore

    var body: some View {
        VStack(spacing: 0) {
            Text("🧑‍🌾")
                .font(.system(size: 38))
                .frame(width: 80, height: 80)
                .background(
                    LinearGradient(
                        colors: [DoplyColor.mint, DoplyColor.sky],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .shadowMd()
                .padding(.bottom, 10)

            Text(store.userName)
                .font(DoplyFont.display(19, .black))
                .foregroundStyle(DoplyColor.ink)

            Text("Level \(store.level)")
                .font(DoplyFont.body(12.5, .bold))
                .foregroundStyle(DoplyColor.greenDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 3)
                .background(DoplyColor.greenSoft, in: Capsule())
                .padding(.top, 6)

            VStack(spacing: 5) {
                HStack {
                    Text("XP")
                    Spacer()
                    Text("\(Int((store.xp * 100).rounded()))%")
                }
                .font(DoplyFont.body(11.5, .bold))
                .foregroundStyle(DoplyColor.inkSoft)

                ProgressTrack(value: store.xp, style: .gold)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats

private struct StatChip: View {
    let data: StatChipData

    var body: some View {
        VStack(spacing: 2) {
            Text(data.value)
                .font(DoplyFont.display(18, .black))
                .foregroundStyle(DoplyColor.ink)
            Text(data.label)
                .font(DoplyFont.body(11, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.md, style: .continuous))
        .shadowSm()
    }
}

// MARK: - Achievements

private struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        Text(achievement.emoji)
            .font(.system(size: 20))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadowSm()
            .opacity(achievement.unlocked ? 1 : 0.35)
    }
}

// MARK: - Settings

private struct SettingsLink: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("⚙️ Settings")
                Spacer()
                Text("›")
            }
            .font(DoplyFont.body(13.5, .bold))
            .foregroundStyle(DoplyColor.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.md, style: .continuous))
            .shadowSm()
        }
        .buttonStyle(PressScaleStyle(scale: 0.98))
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(DoplyStore())
        .environmentObject(ToastCenter())
}
