import SwiftUI

struct ShopScreen: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var toast: ToastCenter
    @State private var selected: ShopCategory = .all

    private var filtered: [ShopItem] {
        selected == .all ? store.shopItems : store.shopItems.filter { $0.category == selected }
    }

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScreenScroll {
            SectionTitle(text: "🛍 Doply Shop", topPadding: 0)

            // Balance
            DoplyCard(padding: 0) {
                HStack {
                    Text("Your balance")
                        .font(DoplyFont.body(13, .bold))
                        .foregroundStyle(DoplyColor.inkSoft)
                    Spacer()
                    Text("🪙 \(store.coins.grouped)")
                        .font(DoplyFont.display(18, .black))
                        .foregroundStyle(DoplyColor.ink)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .padding(.bottom, 16)

            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ShopCategory.allCases) { cat in
                        CategoryChip(category: cat, isActive: cat == selected) {
                            withAnimation(.easeOut(duration: 0.2)) { selected = cat }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .padding(.bottom, 16)

            // Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filtered) { item in
                    ShopItemCard(item: item) {
                        toast.show(item.toast)
                    }
                }
            }
        }
        .background(DoplyColor.cream)
    }
}

private struct CategoryChip: View {
    let category: ShopCategory
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.label)
                .font(DoplyFont.body(12.5, .bold))
                .foregroundStyle(isActive ? DoplyColor.greenDark : DoplyColor.inkSoft)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isActive ? DoplyColor.greenSoft : .white, in: Capsule())
                .overlay(
                    Capsule().stroke(isActive ? DoplyColor.green : .clear, lineWidth: 2)
                )
                .shadowSm()
        }
        .buttonStyle(.plain)
    }
}

private struct ShopItemCard: View {
    let item: ShopItem
    let onBuy: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Text(item.emoji).font(.system(size: 34))

            Text(item.name)
                .font(DoplyFont.body(13, .bold))
                .foregroundStyle(item.isRare ? DoplyColor.rareText : DoplyColor.ink)
                .multilineTextAlignment(.center)

            Text("🪙 \(item.price.grouped)")
                .font(DoplyFont.body(12.5, .bold))
                .foregroundStyle(DoplyColor.coin)

            Button(action: onBuy) {
                Text("Buy")
                    .font(DoplyFont.body(12.5, .heavy))
                    .foregroundStyle(DoplyColor.greenDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(DoplyColor.greenSoft, in: Capsule())
            }
            .buttonStyle(PressScaleStyle(scale: 0.95))
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 16)
        .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous))
        .shadowSm()
    }
}

#Preview {
    ShopScreen()
        .environmentObject(DoplyStore())
        .environmentObject(ToastCenter())
}
