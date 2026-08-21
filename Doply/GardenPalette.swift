import SwiftUI

// MARK: - Garden Palette

/// Sheet that lets the player pick an owned item to place in the garden.
struct GardenPalette: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var gardenStore: GardenStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: ShopCategory = .all

    let onSelect: (ShopItem) -> Void
    var onGoToShop: (() -> Void)? = nil

    private var inventory: [ShopItem] {
        gardenStore.availableInventory(from: store)
    }

    private var filtered: [ShopItem] {
        selectedCategory == .all ? inventory : inventory.filter { $0.category == selectedCategory }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Choose what to plant")
                    .font(DoplyFont.display(17))
                    .foregroundStyle(DoplyColor.ink)
                Text("\(inventory.count) items in your shed")
                    .font(DoplyFont.body(12, .semibold))
                    .foregroundStyle(DoplyColor.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 10)

            if inventory.isEmpty {
                emptyState
            } else {
                categoryChips
                itemGrid
            }
        }
        .background(DoplyColor.cream)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ShopCategory.allCases) { category in
                    GardenCategoryChip(category: category, isActive: category == selectedCategory) {
                        withAnimation(.easeOut(duration: 0.2)) { selectedCategory = category }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
    }

    private var itemGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filtered) { item in
                    GardenPaletteCell(item: item) {
                        onSelect(item)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("🪴 Nothing to plant yet")
                .font(DoplyFont.display(15))
                .foregroundStyle(DoplyColor.ink)
            Text("Visit the Shop to buy seeds, plants and decorations.")
                .font(DoplyFont.body(12.5, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button {
                dismiss()
                onGoToShop?()
            } label: {
                Text("Go to Shop")
                    .font(DoplyFont.body(13, .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(DoplyColor.green, in: Capsule())
            }
            .buttonStyle(PressScaleStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Category Chip

private struct GardenCategoryChip: View {
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
                .overlay(Capsule().stroke(isActive ? DoplyColor.green : .clear, lineWidth: 2))
                .shadowSm()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Palette Cell

private struct GardenPaletteCell: View {
    let item: ShopItem
    let action: () -> Void
    @State private var isSelected = false

    var body: some View {
        Button {
            isSelected = true
            action()
        } label: {
            VStack(spacing: 6) {
                Text(item.emoji).font(.system(size: 34))
                Text(item.name)
                    .font(DoplyFont.body(11, .bold))
                    .foregroundStyle(DoplyColor.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DoplyRadius.md, style: .continuous)
                    .stroke(isSelected ? DoplyColor.green : .clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
            .shadowSm()
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    GardenPalette(onSelect: { _ in })
        .environmentObject(DoplyStore())
        .environmentObject(GardenStore())
        .environmentObject(ToastCenter())
}
