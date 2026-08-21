import SwiftUI

struct FriendsScreen: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var toast: ToastCenter

    var body: some View {
        ScreenScroll {
            SectionTitle(text: "👥 Friends", topPadding: 0)

            DoplyCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(store.friends.enumerated()), id: \.element.id) { idx, friend in
                        FriendRow(friend: friend)
                        if idx < store.friends.count - 1 { RowDivider() }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
            }
            .padding(.bottom, 20)

            SectionTitle(text: "🏆 Weekly Leaderboard", topPadding: 0)

            DoplyCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(store.leaderboard.enumerated()), id: \.element.id) { idx, entry in
                        LeaderboardRow(entry: entry)
                        if idx < store.leaderboard.count - 1 { RowDivider() }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
            }
            .padding(.bottom, 20)

            ChallengeBanner {
                toast.show("Challenge sent to your friends! 🏁")
            }
        }
        .background(DoplyColor.cream)
    }
}

// MARK: - Rows

private struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(DoplyColor.greenSoft)
            .frame(height: 1)
    }
}

private struct FriendRow: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: 12) {
            Text(friend.avatar)
                .font(.system(size: 20))
                .frame(width: 42, height: 42)
                .background(DoplyColor.mint, in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(friend.name)
                    .font(DoplyFont.body(14, .bold))
                    .foregroundStyle(DoplyColor.ink)
                Text("\(friend.stepsToday.grouped) steps today")
                    .font(DoplyFont.body(12, .semibold))
                    .foregroundStyle(DoplyColor.inkSoft)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
    }
}

private struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: 12) {
            Text(entry.medal)
                .font(.system(size: 18))
                .frame(width: 24)
                .multilineTextAlignment(.center)

            Text(entry.name)
                .font(DoplyFont.body(14, .bold))
                .foregroundStyle(DoplyColor.ink)

            Spacer(minLength: 0)

            Text(entry.steps.grouped)
                .font(DoplyFont.body(13, .heavy))
                .foregroundStyle(DoplyColor.ink)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
    }
}

// MARK: - Challenge banner

private struct ChallengeBanner: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("\"Who can walk the most this week?\"")
                .font(DoplyFont.body(14, .bold))
                .foregroundStyle(DoplyColor.ink)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text("Challenge Friends")
                    .font(DoplyFont.display(14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(DoplyColor.water, in: Capsule())
                    .shadow(color: DoplyColor.water.opacity(0.35), radius: 8, y: 8)
            }
            .buttonStyle(PressScaleStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(
            LinearGradient(
                colors: [DoplyColor.skySoft, Color(hex: 0xD8F0FA)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous)
        )
        .shadowSm()
    }
}

#Preview {
    FriendsScreen()
        .environmentObject(DoplyStore())
        .environmentObject(ToastCenter())
}
