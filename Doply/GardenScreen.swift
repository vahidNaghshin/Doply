import SwiftUI

// MARK: - Garden Screen

/// Full-screen interactive garden where the player places owned items on the grass.
struct GardenScreen: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var gardenStore: GardenStore
    @EnvironmentObject private var toast: ToastCenter

    /// Called to close the garden and return to Home (e.g. tapping the ✕).
    let onClose: () -> Void
    /// Called when the player chooses to leave the garden and go shopping (e.g. an empty shed).
    let onGoToShop: () -> Void

    @State private var showPalette = false
    @State private var showClearConfirm = false

    private var inventoryCount: Int {
        gardenStore.availableInventory(from: store).count
    }

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / 400

            ZStack {
                GardenBackdrop(scale: scale)
                    .frame(width: geo.size.width, height: geo.size.height)

                GardenPlacementLayer(canvasSize: geo.size)

                if gardenStore.showWelcome {
                    welcomeOverlay
                }
            }
        }
        .ignoresSafeArea()
        // Floating chrome that always stays within the reachable safe area, even
        // though the canvas above ignores it. This is more reliable than manually
        // reading `GeometryProxy.safeAreaInsets` inside a view that itself ignores
        // the safe area (that combination reports 0 insets), which on real devices
        // with a Dynamic Island/notch could push the close button into a zone the
        // system reserves for its own gestures and never delivers touches to the app.
        .safeAreaInset(edge: .top) {
            topBar
                .padding(.horizontal, 16)
                .padding(.top, 10)
        }
        .safeAreaInset(edge: .bottom) {
            Group {
                if !gardenStore.showWelcome {
                    if gardenStore.pendingMove != nil {
                        moveConfirmationBar
                    } else {
                        bottomActionBar
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            gardenStore.showWelcome = true
        }
        .sheet(isPresented: $showPalette, onDismiss: {
            if gardenStore.mode == .choosingItem {
                gardenStore.mode = .viewing
            }
        }) {
            GardenPalette(
                onSelect: { item in
                    gardenStore.mode = .placing(item)
                },
                onGoToShop: {
                    onGoToShop()
                }
            )
            .presentationDetents([.height(320), .medium])
            .presentationDragIndicator(.visible)
        }
        .confirmationDialog(
            "Clear your whole garden?",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("Clear all", role: .destructive) {
                gardenStore.clearAll()
                toast.show("Garden cleared 🧹")
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                onClose()
            } label: {
                Text("✕")
                    .font(DoplyFont.body(15, .bold))
                    .foregroundStyle(DoplyColor.ink)
                    .frame(width: 36, height: 36)
                    .background(.white, in: Circle())
            }
            .buttonStyle(PressScaleStyle())

            Spacer()

            Text("My Garden")
                .font(DoplyFont.display(16))
                .foregroundStyle(DoplyColor.headerInk)

            Spacer()

            Text("🌿 \(gardenStore.placedItems.count) items")
                .font(DoplyFont.body(12, .bold))
                .foregroundStyle(DoplyColor.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .shadowSm()
    }

    // MARK: - Bottom action bar

    private var bottomActionBar: some View {
        HStack(spacing: 10) {
            Button {
                gardenStore.mode = .choosingItem
                showPalette = true
            } label: {
                HStack(spacing: 8) {
                    Text("🌱").font(.system(size: 16))
                    Text("Place an Item")
                        .font(DoplyFont.display(14))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0x3FA66E), Color(hex: 0x5BBB89), Color(hex: 0x3FA66E)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
                .shadow(color: DoplyColor.green.opacity(0.32), radius: 11, y: 12)
            }
            .buttonStyle(PressScaleStyle())

            Button {
                gardenStore.undoLast()
            } label: {
                Text("↩")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(DoplyColor.ink)
                    .frame(width: 50, height: 50)
                    .background(.white, in: Circle())
                    .shadowSm()
            }
            .buttonStyle(PressScaleStyle())
            .disabled(gardenStore.placedItems.isEmpty)
            .opacity(gardenStore.placedItems.isEmpty ? 0.4 : 1)

            Button {
                showClearConfirm = true
            } label: {
                Text("🗑")
                    .font(.system(size: 17))
                    .frame(width: 50, height: 50)
                    .background(.white, in: Circle())
                    .shadowSm()
            }
            .buttonStyle(PressScaleStyle())
            .disabled(gardenStore.placedItems.isEmpty)
            .opacity(gardenStore.placedItems.isEmpty ? 0.4 : 1)
        }
    }

    // MARK: - Move confirmation bar

    private var moveConfirmationBar: some View {
        let itemName = gardenStore.pendingMove.flatMap { pending in
            gardenStore.placedItems.first(where: { $0.id == pending.itemID })?.name
        } ?? "item"

        return VStack(spacing: 12) {
            Text("Move \(itemName) here?")
                .font(DoplyFont.body(14, .bold))
                .foregroundStyle(DoplyColor.ink)

            HStack(spacing: 10) {
                Button {
                    gardenStore.cancelMove()
                } label: {
                    Text("Cancel")
                        .font(DoplyFont.body(13.5, .heavy))
                        .foregroundStyle(DoplyColor.greenDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(DoplyColor.greenSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(PressScaleStyle())

                Button {
                    let name = itemName
                    gardenStore.confirmMove()
                    toast.show("\(name) moved! 🌿")
                } label: {
                    Text("Confirm ✓")
                        .font(DoplyFont.body(13.5, .heavy))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(DoplyColor.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(PressScaleStyle())
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous))
        .shadowMd()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Welcome overlay

    @ViewBuilder
    private var welcomeOverlay: some View {
        ZStack {
            DoplyColor.ink.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {}

            if inventoryCount == 0 {
                emptyShedCard
            } else {
                welcomeCard
            }
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: gardenStore.showWelcome)
    }

    private var welcomeCard: some View {
        VStack(spacing: 14) {
            Text("🌻").font(.system(size: 46))

            Text("Welcome to your garden, \(store.userName)!")
                .font(DoplyFont.display(20, .black))
                .foregroundStyle(DoplyColor.ink)
                .multilineTextAlignment(.center)

            Text("You've earned \(inventoryCount) items. Tap Place an Item, pick something you own, then tap anywhere on the grass to drop it.")
                .font(DoplyFont.body(13, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
                .multilineTextAlignment(.center)

            Text("💡 Long-press any placed item later to move it.")
                .font(DoplyFont.body(11.5, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.top, 2)

            Button {
                withAnimation { gardenStore.showWelcome = false }
            } label: {
                Text("Let's plant 🌱")
                    .font(DoplyFont.display(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DoplyColor.green, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.top, 6)
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous))
        .shadowMd()
        .padding(.horizontal, 32)
    }

    private var emptyShedCard: some View {
        VStack(spacing: 14) {
            Text("🪴").font(.system(size: 46))

            Text("Your shed is empty")
                .font(DoplyFont.display(18, .black))
                .foregroundStyle(DoplyColor.ink)

            Text("Visit the Shop to buy seeds, plants and decorations for your garden.")
                .font(DoplyFont.body(13, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
                .multilineTextAlignment(.center)

            Button {
                withAnimation { gardenStore.showWelcome = false }
                onGoToShop()
            } label: {
                Text("Go to Shop")
                    .font(DoplyFont.display(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DoplyColor.green, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.top, 6)
        }
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous))
        .shadowMd()
        .padding(.horizontal, 32)
    }
}

// MARK: - Garden Backdrop

/// Reusable sky-to-grass illustration shared between the Home garden preview
/// and the full interactive Garden screen.
struct GardenBackdrop: View {
    let scale: CGFloat

    @State private var drift = false
    @State private var shimmer = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: DoplyColor.skyTop, location: 0.0),
                        .init(color: DoplyColor.skyMid, location: 0.55),
                        .init(color: DoplyColor.sky,    location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                Group {
                    CloudShape()
                        .fill(.white.opacity(0.75))
                        .frame(width: 78 * scale, height: 26 * scale)
                        .position(x: 70 * scale, y: 60 * scale)
                        .offset(x: drift ? 340 * scale : -10 * scale)
                        .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: drift)

                    CloudShape()
                        .fill(.white.opacity(0.65))
                        .frame(width: 70 * scale, height: 24 * scale)
                        .position(x: 320 * scale, y: 80 * scale)
                        .offset(x: drift ? -340 * scale : 10 * scale)
                        .animation(.linear(duration: 42).repeatForever(autoreverses: false), value: drift)
                }
                .clipped()

                VStack {
                    Spacer()
                    ZStack {
                        HillShape(controlSet: 0).fill(Color(hex: 0xAEE0C6).opacity(0.7))
                        HillShape(controlSet: 1).fill(Color(hex: 0x8FCB9C))
                        HillShape(controlSet: 2).fill(Color(hex: 0x6EBB80))

                        StreamShape()
                            .stroke(Color(hex: 0x7FCFEA), style: StrokeStyle(lineWidth: 12 * scale, lineCap: .round))
                            .opacity(0.9)
                        StreamShape()
                            .stroke(Color(hex: 0xD8F3FB), style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round))
                            .opacity(shimmer ? 1 : 0.5)
                            .animation(.easeInOut(duration: 2.4).repeatForever(), value: shimmer)

                        Ellipse()
                            .fill(Color(hex: 0x7FCFEA))
                            .frame(width: 84 * scale, height: 30 * scale)
                            .position(x: 128 * scale, y: 207 * scale)
                        Ellipse()
                            .fill(Color(hex: 0xD8F3FB))
                            .frame(width: 30 * scale, height: 10 * scale)
                            .position(x: 120 * scale, y: 202 * scale)
                            .opacity(shimmer ? 1 : 0.5)
                            .animation(.easeInOut(duration: 2.4).repeatForever(), value: shimmer)

                        FenceView(scale: scale)

                        TreeView(scale: scale, x: 49, groundY: 184, trunkH: 32,
                                 crown: Color(hex: 0x5FAF74), side: Color(hex: 0x6FBF84), radius: 24)
                        TreeView(scale: scale, x: 373, groundY: 186, trunkH: 22,
                                 crown: Color(hex: 0x6FBF84), side: Color(hex: 0x6FBF84), radius: 14, showSides: false)

                        CottageView(scale: scale)
                    }
                    .frame(width: geo.size.width, height: 260 * scale)
                }
            }
        }
        .onAppear { drift = true; shimmer = true }
    }
}

#Preview {
    GardenScreen(onClose: {}, onGoToShop: {})
        .environmentObject(DoplyStore())
        .environmentObject(GardenStore())
        .environmentObject(ToastCenter())
}
