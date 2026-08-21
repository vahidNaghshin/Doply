import SwiftUI

@main
struct DoplyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

enum DoplyTab: String, CaseIterable, Identifiable {
    case home, quests, shop, friends, profile
    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:    return "Home"
        case .quests:  return "Quests"
        case .shop:    return "Shop"
        case .friends: return "Friends"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home:    return "🏠"
        case .quests:  return "🏆"
        case .shop:    return "🏬"
        case .friends: return "👥"
        case .profile: return "👤"
        }
    }
}

struct RootView: View {
    @StateObject private var store = DoplyStore()
    @StateObject private var toast = ToastCenter()
    @State private var tab: DoplyTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            DoplyColor.cream.ignoresSafeArea()

            // Screens — each keeps its own scroll position.
            Group {
                switch tab {
                case .home:    HomeScreen()
                case .quests:  QuestsScreen()
                case .shop:    ShopScreen()
                case .friends: FriendsScreen()
                case .profile: ProfileScreen()
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .animation(.easeOut(duration: 0.28), value: tab)

            if let message = toast.message {
                ToastView(text: message)
                    .padding(.bottom, 100)
                    .zIndex(40)
            }

            BottomNavBar(selection: $tab)
        }
        .environmentObject(store)
        .environmentObject(toast)
    }
}

// MARK: - Bottom Nav

struct BottomNavBar: View {
    @Binding var selection: DoplyTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DoplyTab.allCases) { item in
                let isActive = item == selection
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { selection = item }
                } label: {
                    VStack(spacing: 3) {
                        Text(item.icon).font(.system(size: 20))
                        Text(item.title).font(DoplyFont.body(10.5, .bold))
                    }
                    .foregroundStyle(isActive ? DoplyColor.greenDark : DoplyColor.inkSoft)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isActive ? DoplyColor.greenSoft : .clear)
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 82)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DoplyColor.ink.opacity(0.06))
                .frame(height: 1)
        }
    }
}

// MARK: - Shared screen scaffold

struct ScreenScroll<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) { content }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 110)
        }
    }
}
