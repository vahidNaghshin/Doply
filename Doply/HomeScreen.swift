import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var toast: ToastCenter
    @State private var showWalkSession = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HomeSkyHeader()

                VStack(spacing: 0) {
                    ProgressCard().padding(.top, 16)
                    StartMovingButton { showWalkSession = true }.padding(.top, 16)
                    UpcomingMissionCard().padding(.top, 14)
                }
                .padding(.horizontal, 18)
            }
            .padding(.bottom, 110)
        }
        .background(DoplyColor.cream)
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showWalkSession) {
            WalkSessionView()
        }
    }
}

// MARK: - Sky header (greeting + balances + garden)

private struct HomeSkyHeader: View {
    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Good morning, Alex! ☀️")
                        .font(DoplyFont.display(18.5))
                        .foregroundStyle(DoplyColor.headerInk)
                    Text("Move more, grow more.")
                        .font(DoplyFont.body(12, .semibold))
                        .foregroundStyle(DoplyColor.headerSub)
                }
                Spacer(minLength: 4)
                BalancesStack()
            }
            .padding(.horizontal, 18)
            .padding(.top, 56)   // status-bar / notch clearance

            GardenHero()
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: DoplyColor.skyTop, location: 0.0),
                    .init(color: DoplyColor.skyMid, location: 0.7),
                    .init(color: DoplyColor.sky,    location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 36,
                bottomTrailingRadius: 36,
                style: .continuous
            )
        )
    }
}

private struct BalancesStack: View {
    @EnvironmentObject private var store: DoplyStore

    var body: some View {
        VStack(spacing: 8) {
            BalanceCard(icon: "🪙", tint: DoplyColor.yellowSoft,
                        value: store.coins.grouped, label: "Doply Coins")
            BalanceCard(icon: "💧", tint: DoplyColor.skySoft,
                        value: "\(store.water)", label: "Water")
        }
    }
}

private struct BalanceCard: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 7) {
            Text(icon)
                .font(.system(size: 14))
                .frame(width: 26, height: 26)
                .background(tint, in: Circle())

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(DoplyFont.display(13.5))
                    .foregroundStyle(DoplyColor.headerInk)
                Text(label)
                    .font(DoplyFont.body(9, .semibold))
                    .foregroundStyle(DoplyColor.headerLbl)
            }

            Text("+")
                .font(DoplyFont.display(12))
                .foregroundStyle(DoplyColor.greenDark)
                .frame(width: 19, height: 19)
                .background(Color(hex: 0xEAF6EE), in: Circle())
        }
        .padding(6)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadowSm()
    }
}

// MARK: - Garden illustration

private struct GardenHero: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let s = w / 400   // illustration authored on a 400-wide canvas

            ZStack(alignment: .bottom) {
                GardenCanvas(scale: s)
                    .frame(width: w, height: 260 * s)

                HStack {
                    HeroFab(icon: "📷", label: "Snapshot")
                    Spacer()
                    HeroFab(icon: "🌱", label: "Garden Boost")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
            .frame(width: w, height: 260 * s)
        }
        .aspectRatio(400.0 / 260.0, contentMode: .fit)
    }
}

private struct HeroFab: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Text(icon)
                .font(.system(size: 18))
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.92), in: Circle())
                .shadowMd()
            Text(label)
                .font(DoplyFont.body(9.5, .bold))
                .foregroundStyle(.white)
                .shadow(color: Color(hex: 0x143228).opacity(0.45), radius: 4, y: 1)
        }
    }
}

/// Layered, gently-animated garden scene (Shape/Path port of the original SVG).
private struct GardenCanvas: View {
    let scale: CGFloat

    @State private var sway = false
    @State private var flutter = false
    @State private var shimmer = false
    @State private var drift = false

    var body: some View {
        ZStack {
            // Clouds
            Group {
                CloudShape()
                    .fill(.white.opacity(0.75))
                    .frame(width: 78 * scale, height: 26 * scale)
                    .position(x: 70 * scale, y: 28 * scale)
                    .offset(x: drift ? 340 * scale : -10 * scale)
                    .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: drift)

                CloudShape()
                    .fill(.white.opacity(0.65))
                    .frame(width: 70 * scale, height: 24 * scale)
                    .position(x: 320 * scale, y: 36 * scale)
                    .offset(x: drift ? -340 * scale : 10 * scale)
                    .animation(.linear(duration: 42).repeatForever(autoreverses: false), value: drift)
            }
            .clipped()

            // Rolling hills
            HillShape(controlSet: 0).fill(Color(hex: 0xAEE0C6).opacity(0.7))
            HillShape(controlSet: 1).fill(Color(hex: 0x8FCB9C))
            HillShape(controlSet: 2).fill(Color(hex: 0x6EBB80))

            // Stream
            StreamShape()
                .stroke(Color(hex: 0x7FCFEA), style: StrokeStyle(lineWidth: 12 * scale, lineCap: .round))
                .opacity(0.9)
            StreamShape()
                .stroke(Color(hex: 0xD8F3FB), style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round))
                .opacity(shimmer ? 1 : 0.5)
                .animation(.easeInOut(duration: 2.4).repeatForever(), value: shimmer)

            // Pond
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

            // Stones
            Circle().fill(Color(hex: 0xB9AFA2))
                .frame(width: 14 * scale).position(x: 248 * scale, y: 146 * scale)
            Circle().fill(Color(hex: 0xCFC5B7))
                .frame(width: 10 * scale).position(x: 258 * scale, y: 150 * scale)

            // Fence
            FenceView(scale: scale)

            // Trees
            TreeView(scale: scale, x: 49, groundY: 184, trunkH: 32,
                     crown: Color(hex: 0x5FAF74), side: Color(hex: 0x6FBF84), radius: 24)
                .modifier(SwayEffect(active: sway, duration: 3.6, delay: 0))

            TreeView(scale: scale, x: 316, groundY: 180, trunkH: 34,
                     crown: Color(hex: 0xF6C6D9), side: Color(hex: 0xFBD7E4), radius: 25)
                .modifier(SwayEffect(active: sway, duration: 4.4, delay: 0.4))

            TreeView(scale: scale, x: 373, groundY: 186, trunkH: 22,
                     crown: Color(hex: 0x6FBF84), side: Color(hex: 0x6FBF84), radius: 14, showSides: false)
                .modifier(SwayEffect(active: sway, duration: 3.1, delay: 0.2))

            TreeView(scale: scale, x: 20, groundY: 192, trunkH: 16,
                     crown: Color(hex: 0x6FBF84), side: Color(hex: 0x6FBF84), radius: 11, showSides: false)
                .modifier(SwayEffect(active: sway, duration: 3.1, delay: 0.5))

            // Cottage
            CottageView(scale: scale)

            // Flowers
            FlowersView(scale: scale)

            // Butterflies
            ButterflyView(scale: scale, bodyColor: Color(hex: 0x3B2A1E),
                          wing: Color(hex: 0xF5A94B), x: 156, y: 88, size: 1.0)
                .modifier(FlutterEffect(active: flutter, duration: 4.5, delay: 0, scale: scale))

            ButterflyView(scale: scale, bodyColor: Color(hex: 0x2E4E6E),
                          wing: Color(hex: 0x6FB8F0), x: 295, y: 104, size: 0.9)
                .modifier(FlutterEffect(active: flutter, duration: 5.2, delay: 0.6, scale: scale))
        }
        .onAppear {
            sway = true; flutter = true; shimmer = true; drift = true
        }
    }
}

// MARK: Garden sub-shapes

private struct CloudShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addEllipse(in: CGRect(x: 0, y: r.height * 0.35,
                                width: r.width * 0.72, height: r.height * 0.65))
        p.addEllipse(in: CGRect(x: r.width * 0.32, y: 0,
                                width: r.width * 0.55, height: r.height * 0.7))
        return p
    }
}

private struct HillShape: Shape {
    let controlSet: Int   // 0 = back, 1 = mid, 2 = front

    func path(in r: CGRect) -> Path {
        let sx = r.width / 400, sy = r.height / 260
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }

        var p = Path()
        switch controlSet {
        case 0:
            p.move(to: pt(0, 120))
            p.addCurve(to: pt(190, 105), control1: pt(60, 100),  control2: pt(120, 118))
            p.addCurve(to: pt(400, 100), control1: pt(260, 94),  control2: pt(330, 112))
        case 1:
            p.move(to: pt(0, 150))
            p.addCurve(to: pt(170, 134), control1: pt(60, 124),  control2: pt(110, 148))
            p.addCurve(to: pt(330, 130), control1: pt(230, 120), control2: pt(270, 144))
            p.addCurve(to: pt(400, 126), control1: pt(360, 122), control2: pt(385, 132))
        default:
            p.move(to: pt(0, 172))
            p.addCurve(to: pt(200, 158), control1: pt(70, 150),  control2: pt(130, 174))
            p.addCurve(to: pt(400, 152), control1: pt(260, 144), control2: pt(310, 166))
        }
        p.addLine(to: pt(400, 260))
        p.addLine(to: pt(0, 260))
        p.closeSubpath()
        return p
    }
}

private struct StreamShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 400, sy = r.height / 260
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }

        var p = Path()
        p.move(to: pt(255, 150))
        p.addCurve(to: pt(300, 178), control1: pt(275, 158), control2: pt(280, 172))
        p.addCurve(to: pt(366, 190), control1: pt(325, 185), control2: pt(345, 182))
        return p
    }
}

private struct FenceView: View {
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array([(10.0, 192.0), (24.0, 192.0), (38.0, 190.0)].enumerated()),
                    id: \.offset) { _, pair in
                Rectangle()
                    .fill(Color(hex: 0xE4C9A6))
                    .frame(width: 4 * scale, height: 18 * scale)
                    .offset(x: pair.0 * scale, y: pair.1 * scale)
            }
            Rectangle()
                .fill(Color(hex: 0xD8B98E))
                .frame(width: 38 * scale, height: 3 * scale)
                .offset(x: 8 * scale, y: 196 * scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .opacity(0.85)
    }
}

private struct TreeView: View {
    let scale: CGFloat
    let x: CGFloat
    let groundY: CGFloat
    let trunkH: CGFloat
    let crown: Color
    let side: Color
    let radius: CGFloat
    var showSides: Bool = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3 * scale)
                .fill(Color(hex: 0x9A6B43))
                .frame(width: 9 * scale, height: trunkH * scale)
                .position(x: x * scale, y: (groundY - trunkH / 2) * scale)

            if showSides {
                Circle().fill(side)
                    .frame(width: radius * 1.42 * scale)
                    .position(x: (x - 16) * scale, y: (groundY - trunkH - 2) * scale)
                Circle().fill(side)
                    .frame(width: radius * 1.42 * scale)
                    .position(x: (x + 18) * scale, y: (groundY - trunkH - 2) * scale)
            }

            Circle().fill(crown)
                .frame(width: radius * 2 * scale)
                .position(x: x * scale, y: (groundY - trunkH - 12) * scale)
        }
    }
}

private struct CottageView: View {
    let scale: CGFloat

    var body: some View {
        ZStack {
            // Walls
            RoundedRectangle(cornerRadius: 4 * scale)
                .fill(Color(hex: 0xFFF3E2))
                .frame(width: 60 * scale, height: 42 * scale)
                .position(x: 220 * scale, y: 173 * scale)

            // Roof
            RoofShape()
                .fill(Color(hex: 0xE88B6B))
                .frame(width: 70 * scale, height: 28 * scale)
                .position(x: 220 * scale, y: 140 * scale)

            // Chimney
            Rectangle()
                .fill(Color(hex: 0xC46E4E))
                .frame(width: 8 * scale, height: 14 * scale)
                .position(x: 218 * scale, y: 135 * scale)

            // Door
            RoundedRectangle(cornerRadius: 2 * scale)
                .fill(Color(hex: 0xB4794F))
                .frame(width: 14 * scale, height: 24 * scale)
                .position(x: 217 * scale, y: 182 * scale)

            // Window
            Circle()
                .fill(Color(hex: 0xFFD166))
                .overlay(Circle().stroke(Color(hex: 0xE8A93E), lineWidth: 1.5 * scale))
                .frame(width: 14 * scale)
                .position(x: 240 * scale, y: 166 * scale)
        }
    }
}

private struct RoofShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: r.maxY))
        p.addLine(to: CGPoint(x: r.midX, y: 0))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

private struct FlowersView: View {
    let scale: CGFloat

    private let flowers: [(CGFloat, CGFloat, CGFloat, Color)] = [
        (150, 192, 6, DoplyColor.yellow),
        (163, 196, 5, Color(hex: 0xFF9FB8)),
        (270, 204, 5, .white),
        (281, 198, 6, DoplyColor.yellow),
        ( 92, 200, 5, Color(hex: 0xFF9FB8)),
        (105, 204, 5, .white)
    ]

    var body: some View {
        ZStack {
            ForEach(Array(flowers.enumerated()), id: \.offset) { _, f in
                Circle()
                    .fill(f.3)
                    .frame(width: f.2 * 2 * scale)
                    .position(x: f.0 * scale, y: f.1 * scale)
            }
        }
    }
}

private struct ButterflyView: View {
    let scale: CGFloat
    let bodyColor: Color
    let wing: Color
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse().fill(wing)
                .frame(width: 18 * size * scale, height: 12 * size * scale)
                .rotationEffect(.degrees(-18))
                .offset(x: -6 * size * scale)
            Ellipse().fill(wing)
                .frame(width: 18 * size * scale, height: 12 * size * scale)
                .rotationEffect(.degrees(18))
                .offset(x: 6 * size * scale)
            RoundedRectangle(cornerRadius: 2 * scale)
                .fill(bodyColor)
                .frame(width: 4 * size * scale, height: 10 * size * scale)
        }
        .position(x: x * scale, y: y * scale)
    }
}

// MARK: Animation modifiers

private struct SwayEffect: ViewModifier {
    let active: Bool
    let duration: Double
    let delay: Double

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active ? 1.2 : -1.2), anchor: .bottom)
            .animation(
                .easeInOut(duration: duration).repeatForever().delay(delay),
                value: active
            )
    }
}

private struct FlutterEffect: ViewModifier {
    let active: Bool
    let duration: Double
    let delay: Double
    let scale: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(x: active ? 4 * scale : -6 * scale,
                    y: active ? -18 * scale : 0)
            .rotationEffect(.degrees(active ? 3 : -4))
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay),
                value: active
            )
    }
}

// MARK: - Progress card

private struct ProgressCard: View {
    @EnvironmentObject private var store: DoplyStore

    var body: some View {
        DoplyCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 13) {
                    ProgressRing(value: store.stepProgress, icon: "🚶")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("TODAY'S PROGRESS")
                            .font(DoplyFont.body(10, .heavy))
                            .kerning(0.4)
                            .foregroundStyle(DoplyColor.inkSoft)
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(store.steps.grouped)
                                .font(DoplyFont.display(22, .black))
                                .foregroundStyle(DoplyColor.ink)
                            Text("/ \(store.stepGoal.grouped) steps")
                                .font(DoplyFont.body(12, .semibold))
                                .foregroundStyle(DoplyColor.inkSoft)
                        }
                    }

                    Spacer(minLength: 0)

                    Text("\(store.stepPercent)%")
                        .font(DoplyFont.display(15.5))
                        .foregroundStyle(DoplyColor.greenDark)
                }

                ProgressTrack(value: store.stepProgress)
                    .padding(.top, 14)

                Text("🍃 \(store.stepsRemaining.grouped) steps left to grow your tree 🌳")
                    .font(DoplyFont.body(11.5, .semibold))
                    .foregroundStyle(DoplyColor.inkSoft)
                    .padding(.top, 12)

                Rectangle()
                    .fill(DoplyColor.greenSoft)
                    .frame(height: 1)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                HStack {
                    Text("TODAY'S REWARDS")
                        .font(DoplyFont.body(10, .heavy))
                        .kerning(0.4)
                        .foregroundStyle(DoplyColor.inkSoft)
                    Spacer()
                    Text("See all ›")
                        .font(DoplyFont.body(12, .bold))
                        .foregroundStyle(DoplyColor.greenDark)
                }
                .padding(.bottom, 10)

                HStack(spacing: 0) {
                    RewardItem(icon: "🪙", value: "+60",     label: "Doply Coins")
                    RewardDivider()
                    RewardItem(icon: "💧", value: "+15",     label: "Water")
                    RewardDivider()
                    RewardItem(icon: "🌱", value: "Common",  label: "Seed")
                }
            }
        }
    }
}

private struct RewardItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 1) {
            Text(icon).font(.system(size: 19)).padding(.bottom, 3)
            Text(value)
                .font(DoplyFont.display(13))
                .foregroundStyle(DoplyColor.ink)
            Text(label)
                .font(DoplyFont.body(9.5, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RewardDivider: View {
    var body: some View {
        Rectangle()
            .fill(DoplyColor.greenSoft)
            .frame(width: 1)
            .padding(.vertical, 6)
    }
}

// MARK: - Primary CTA

private struct StartMovingButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("👟")
                    .font(.system(size: 20))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.22), in: Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text("Start Moving")
                        .font(DoplyFont.display(15))
                        .foregroundStyle(.white)
                    Text("Let's grow your world!")
                        .font(DoplyFont.body(11, .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer(minLength: 0)

                Text("›")
                    .font(DoplyFont.body(15, .bold))
                    .foregroundStyle(.white)
                    .frame(width: 27, height: 27)
                    .background(.white.opacity(0.22), in: Circle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
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
    }
}

// MARK: - Mission card

private struct UpcomingMissionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Text("🚩")
                    .font(.system(size: 17))
                    .frame(width: 38, height: 38)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadowSm()

                VStack(alignment: .leading, spacing: 2) {
                    Text("UPCOMING MISSION")
                        .font(DoplyFont.body(9.5, .heavy))
                        .kerning(0.4)
                        .foregroundStyle(DoplyColor.missionAccent)
                    Text("Walk 10,000 steps")
                        .font(DoplyFont.display(14))
                        .foregroundStyle(DoplyColor.ink)
                    Text("2 days left")
                        .font(DoplyFont.body(11, .semibold))
                        .foregroundStyle(DoplyColor.inkSoft)
                }

                Spacer(minLength: 0)

                Text("+100 🪙")
                    .font(DoplyFont.display(12.5))
                    .foregroundStyle(DoplyColor.ink)
            }

            HStack(spacing: 8) {
                ProgressTrack(value: 0.48, style: .purple, height: 8)
                Text("48%")
                    .font(DoplyFont.body(11, .bold))
                    .foregroundStyle(DoplyColor.missionAccent)
            }
        }
        .padding(16)
        .background(DoplyColor.missionBG,
                    in: RoundedRectangle(cornerRadius: DoplyRadius.lg, style: .continuous))
    }
}

#Preview {
    RootView()
}
