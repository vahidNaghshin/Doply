import SwiftUI
import UIKit

// MARK: - Garden Placement Layer

/// Renders every placed item and owns all placement / re-drag / removal gestures
/// for the interactive garden canvas.
struct GardenPlacementLayer: View {
    @EnvironmentObject private var gardenStore: GardenStore
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var toast: ToastCenter

    let canvasSize: CGSize

    @State private var ghostPosition: CGPoint?
    @State private var contextItemID: UUID?

    var body: some View {
        ZStack {
            // Background dismiss layer: tapping empty space clears the context bubble,
            // and (while placing) attempts to drop the pending item. Only hit-tested
            // while it actually needs to intercept touches, so it never steals taps
            // meant for the top/bottom bars (e.g. the close button) the rest of the time.
            Color.clear
                .contentShape(Rectangle())
                .gesture(backgroundGesture)
                .allowsHitTesting(isBackgroundGestureActive)

            if case .placing(let item) = gardenStore.mode {
                plantableZoneOutline
                instructionBanner(for: item)
                ghost(for: item)
            }

            ForEach(gardenStore.placedItems.sorted(by: { $0.zIndex < $1.zIndex })) { item in
                placedItemView(item)
            }

            if let contextItemID, let item = gardenStore.placedItems.first(where: { $0.id == contextItemID }) {
                contextBubble(for: item)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    /// Whether the full-canvas background layer needs to intercept touches right now
    /// (placing a new item, or dismissing an open context bubble). Kept `false`
    /// otherwise so it never blocks taps on the surrounding chrome (close button, etc).
    private var isBackgroundGestureActive: Bool {
        if case .placing = gardenStore.mode { return true }
        return contextItemID != nil
    }

    // MARK: - Placed items

    @ViewBuilder
    private func placedItemView(_ item: PlacedItem) -> some View {
        let isBeingMoved = gardenStore.mode == .moving(item.id)
        let point = denormalize(item.position)

        ZStack {
            Ellipse()
                .fill(.black.opacity(0.12))
                .frame(width: 30 * item.scale, height: 9 * item.scale)
                .offset(y: 16 * item.scale)

            Text(item.emoji)
                .font(.system(size: 38 * item.scale))
                .shadow(color: .black.opacity(0.18), radius: 3, y: 3)
        }
        .scaleEffect(isBeingMoved ? 1.15 : 1.0)
        .position(point)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isBeingMoved)
        .zIndex(isBeingMoved ? 999 : item.zIndex)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                contextItemID = (contextItemID == item.id) ? nil : item.id
            }
        }
        .gesture(moveGesture(for: item))
        .allowsHitTesting(gardenStore.mode == .viewing || isBeingMoved)
    }

    private func moveGesture(for item: PlacedItem) -> some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .onEnded { _ in
                contextItemID = nil
                gardenStore.beginMove(item.id)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                guard case .second(true, let drag?) = value,
                      case .moving(let id) = gardenStore.mode, id == item.id,
                      let pending = gardenStore.pendingMove else { return }
                let startPixel = denormalize(pending.originalPosition)
                let newPixel = CGPoint(x: startPixel.x + drag.translation.width,
                                        y: startPixel.y + drag.translation.height)
                gardenStore.updateProposed(id, to: normalize(newPixel))
            }
    }

    // MARK: - Placing (new item) mode

    @ViewBuilder
    private func ghost(for item: ShopItem) -> some View {
        if let ghostPosition {
            Text(item.emoji)
                .font(.system(size: 38))
                .opacity(0.55)
                .position(ghostPosition)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
    }

    private var plantableZoneOutline: some View {
        let rect = plantableRect
        return RoundedRectangle(cornerRadius: 20)
            .strokeBorder(DoplyColor.green.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [7, 6]))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }

    private func instructionBanner(for item: ShopItem) -> some View {
        VStack {
            Text("Tap the grass to drop \(item.name)")
                .font(DoplyFont.body(12.5, .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(DoplyColor.ink.opacity(0.85), in: Capsule())
                .padding(.top, 70)
            Spacer()
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .allowsHitTesting(false)
    }

    private var backgroundGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard case .placing = gardenStore.mode else { return }
                ghostPosition = value.location
            }
            .onEnded { value in
                if contextItemID != nil {
                    contextItemID = nil
                }
                guard case .placing(let item) = gardenStore.mode else { return }
                defer { ghostPosition = nil }
                let normalized = normalize(value.location)
                if GardenStore.isInPlantableZone(normalized) {
                    gardenStore.place(item, at: normalized)
                    toast.show("\(item.name) planted! \(item.emoji)")
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    toast.show("Plants need soil — try the grass 🌱")
                }
            }
    }

    // MARK: - Context bubble

    private func contextBubble(for item: PlacedItem) -> some View {
        let point = denormalize(item.position)
        return HStack(spacing: 8) {
            Button {
                contextItemID = nil
                gardenStore.beginMove(item.id)
            } label: {
                Text("↔ Move")
                    .font(DoplyFont.body(12, .bold))
                    .foregroundStyle(DoplyColor.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DoplyColor.greenSoft, in: Capsule())
            }
            .buttonStyle(PressScaleStyle(scale: 0.94))

            Button {
                contextItemID = nil
                gardenStore.remove(item.id)
                toast.show("\(item.name) removed")
            } label: {
                Text("🗑 Remove")
                    .font(DoplyFont.body(12, .bold))
                    .foregroundStyle(DoplyColor.ink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DoplyColor.greenSoft, in: Capsule())
            }
            .buttonStyle(PressScaleStyle(scale: 0.94))
        }
        .padding(6)
        .background(.white, in: Capsule())
        .shadowMd()
        .position(x: point.x, y: point.y - 50)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    // MARK: - Coordinate helpers

    private var plantableRect: CGRect {
        let xRange = GardenStore.plantableX
        let yRange = GardenStore.plantableY
        let origin = CGPoint(x: xRange.lowerBound * canvasSize.width, y: yRange.lowerBound * canvasSize.height)
        let size = CGSize(width: (xRange.upperBound - xRange.lowerBound) * canvasSize.width,
                           height: (yRange.upperBound - yRange.lowerBound) * canvasSize.height)
        return CGRect(origin: origin, size: size)
    }

    private func denormalize(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x * canvasSize.width, y: p.y * canvasSize.height)
    }

    private func normalize(_ p: CGPoint) -> CGPoint {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return .zero }
        return CGPoint(x: p.x / canvasSize.width, y: p.y / canvasSize.height)
    }
}

// MARK: - Preview

#Preview {
    GardenPlacementLayer(canvasSize: CGSize(width: 390, height: 700))
        .environmentObject(DoplyStore())
        .environmentObject(GardenStore())
        .environmentObject(ToastCenter())
}
