import SwiftUI
import Combine

// MARK: - Placed Item

/// A single decoration/plant/animal the player has dropped into their garden.
struct PlacedItem: Identifiable, Codable, Equatable {
    let id: UUID
    let sourceItemID: UUID       // links back to ShopItem.id
    let emoji: String
    let name: String
    var position: CGPoint        // normalized 0...1 relative to the garden canvas
    var scale: CGFloat           // 0.8...1.4, default 1.0
    var zIndex: Double           // higher = drawn in front; derived from position.y
    var placedAt: Date
}

// MARK: - Garden Mode

/// The current interaction state of the garden canvas.
enum GardenMode: Equatable {
    case viewing               // idle, nothing selected
    case choosingItem          // palette sheet open, picking what to place
    case placing(ShopItem)     // ghost preview follows finger, awaiting drop
    case moving(UUID)          // dragging an already-placed item

    static func == (lhs: GardenMode, rhs: GardenMode) -> Bool {
        switch (lhs, rhs) {
        case (.viewing, .viewing):
            return true
        case (.choosingItem, .choosingItem):
            return true
        case (.placing(let a), .placing(let b)):
            return a.id == b.id
        case (.moving(let a), .moving(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Garden Store

/// Owns the persisted layout of the player's garden and all placement/move interactions.
@MainActor
final class GardenStore: ObservableObject {
    @Published var placedItems: [PlacedItem] = []
    @Published var mode: GardenMode = .viewing
    @Published var showWelcome: Bool = true
    @Published var pendingMove: PendingMove? = nil

    /// A re-drag in progress: where the item started and where it's proposed to move.
    struct PendingMove: Equatable {
        let itemID: UUID
        let originalPosition: CGPoint
        let proposedPosition: CGPoint
    }

    /// Horizontal bounds of the plantable grass area (normalized 0...1).
    static let plantableX: ClosedRange<CGFloat> = 0.04...0.96
    /// Vertical bounds of the plantable grass area (normalized 0...1). Anything
    /// above this is sky and is not a valid drop target.
    static let plantableY: ClosedRange<CGFloat> = 0.55...0.94

    private static let storageKey = "doply.garden.placedItems"

    init() {
        load()
    }

    /// Clamps a normalized point so it always stays within the plantable grass zone.
    static func clampToPlantable(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, plantableX.lowerBound), plantableX.upperBound),
            y: min(max(point.y, plantableY.lowerBound), plantableY.upperBound)
        )
    }

    /// Whether a normalized point falls inside the plantable grass zone.
    static func isInPlantableZone(_ point: CGPoint) -> Bool {
        plantableX.contains(point.x) && plantableY.contains(point.y)
    }

    /// Adds a new placed item at the given normalized position and returns to viewing mode.
    func place(_ item: ShopItem, at normalized: CGPoint) {
        let clamped = Self.clampToPlantable(normalized)
        let placed = PlacedItem(
            id: UUID(),
            sourceItemID: item.id,
            emoji: item.emoji,
            name: item.name,
            position: clamped,
            scale: 1.0,
            zIndex: Double(clamped.y),
            placedAt: Date()
        )
        placedItems.append(placed)
        mode = .viewing
        save()
    }

    /// Begins re-dragging an already-placed item, remembering its starting position
    /// so the move can be cancelled and reverted later.
    func beginMove(_ id: UUID) {
        guard let item = placedItems.first(where: { $0.id == id }) else { return }
        pendingMove = PendingMove(itemID: id, originalPosition: item.position, proposedPosition: item.position)
        mode = .moving(id)
    }

    /// Live-updates the dragged item's on-screen position while the user's finger moves.
    func updateProposed(_ id: UUID, to normalized: CGPoint) {
        guard let pending = pendingMove, pending.itemID == id else { return }
        let clamped = Self.clampToPlantable(normalized)
        pendingMove = PendingMove(itemID: id, originalPosition: pending.originalPosition, proposedPosition: clamped)
        guard let index = placedItems.firstIndex(where: { $0.id == id }) else { return }
        placedItems[index].position = clamped
    }

    /// Commits the proposed position, recalculates draw order, and clears the pending move.
    func confirmMove() {
        defer {
            pendingMove = nil
            mode = .viewing
        }
        guard let pending = pendingMove,
              let index = placedItems.firstIndex(where: { $0.id == pending.itemID }) else { return }
        placedItems[index].position = pending.proposedPosition
        placedItems[index].zIndex = Double(pending.proposedPosition.y)
        save()
    }

    /// Restores the item to where it was before the drag began and clears the pending move.
    func cancelMove() {
        if let pending = pendingMove,
           let index = placedItems.firstIndex(where: { $0.id == pending.itemID }) {
            placedItems[index].position = pending.originalPosition
        }
        pendingMove = nil
        mode = .viewing
    }

    /// Removes a placed item from the garden entirely.
    func remove(_ id: UUID) {
        placedItems.removeAll { $0.id == id }
        save()
    }

    /// Removes the most recently placed item.
    func undoLast() {
        guard !placedItems.isEmpty else { return }
        placedItems.removeLast()
        save()
    }

    /// Removes every placed item from the garden.
    func clearAll() {
        placedItems.removeAll()
        save()
    }

    /// Shop items the player currently owns and can place in the garden.
    func availableInventory(from store: DoplyStore) -> [ShopItem] {
        store.shopItems.filter { store.owns($0) }
    }

    // MARK: Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(placedItems) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([PlacedItem].self, from: data) else { return }
        placedItems = decoded
    }
}
