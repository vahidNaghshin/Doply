import SwiftUI
import Combine

// MARK: - Design Tokens

enum DoplyColor {
    static let green      = Color(hex: 0x3FA66E)
    static let greenDark  = Color(hex: 0x1F5C3E)
    static let greenSoft  = Color(hex: 0xDCF3E4)
    static let mint       = Color(hex: 0xB8ECD1)
    static let sky        = Color(hex: 0x8FD8F2)
    static let skySoft    = Color(hex: 0xE4F6FC)
    static let yellow     = Color(hex: 0xFFCB57)
    static let yellowSoft = Color(hex: 0xFFF3D6)
    static let cream      = Color(hex: 0xFFF8EC)
    static let cream2     = Color(hex: 0xFFFDF9)
    static let coin       = Color(hex: 0xF0A83E)
    static let water      = Color(hex: 0x3FAEE0)
    static let pink       = Color(hex: 0xFFB4C6)
    static let ink        = Color(hex: 0x20463A)
    static let inkSoft    = Color(hex: 0x6C8A7C)

    // Sky gradient (home header)
    static let skyTop     = Color(hex: 0xCFEFFB)
    static let skyMid     = Color(hex: 0x9FDCF2)

    // Mission card
    static let missionBG      = Color(hex: 0xEFECFC)
    static let missionAccent  = Color(hex: 0x7C6EE8)
    static let missionTrack   = Color(hex: 0xDCD7F7)
    static let purpleA        = Color(hex: 0x8B7CF6)
    static let purpleB        = Color(hex: 0xB2A6FA)

    // Streak banner
    static let streakA    = Color(hex: 0xFFE3B0)
    static let streakNum  = Color(hex: 0x8A5A12)
    static let streakLbl  = Color(hex: 0xA17324)

    static let rareText   = Color(hex: 0xB4790B)
    static let headerInk  = Color(hex: 0x1B3A52)
    static let headerSub  = Color(hex: 0x3E6480)
    static let headerLbl  = Color(hex: 0x5D7A8C)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >>  8) & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum DoplyRadius {
    static let lg: CGFloat = 26
    static let md: CGFloat = 18
    static let sm: CGFloat = 12
}

enum DoplyFont {
    /// Stand-in for "Nunito" (display). Swap `.rounded` for `.custom("Nunito-...")`
    /// once the font files are bundled.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    /// Stand-in for "Inter" (body).
    static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Shadows

extension View {
    func shadowSm() -> some View {
        shadow(color: DoplyColor.ink.opacity(0.08), radius: 7, x: 0, y: 4)
    }
    func shadowMd() -> some View {
        shadow(color: DoplyColor.ink.opacity(0.14), radius: 14, x: 0, y: 10)
    }
}

// MARK: - Card

struct DoplyCard<Content: View>: View {
    var padding: CGFloat = 18
    var radius: CGFloat = DoplyRadius.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadowSm()
    }
}

// MARK: - Progress Bar

struct ProgressTrack: View {
    enum Style {
        case green, gold, blue, purple

        var gradient: LinearGradient {
            let colors: [Color]
            switch self {
            case .green:  colors = [DoplyColor.green, DoplyColor.mint]
            case .gold:   colors = [DoplyColor.coin, DoplyColor.yellow]
            case .blue:   colors = [DoplyColor.water, DoplyColor.sky]
            case .purple: colors = [DoplyColor.purpleA, DoplyColor.purpleB]
            }
            return LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        }

        var track: Color {
            self == .purple ? DoplyColor.missionTrack : DoplyColor.greenSoft
        }
    }

    var value: Double            // 0...1
    var style: Style = .green
    var height: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(style.track)
                Capsule()
                    .fill(style.gradient)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
                    .animation(.easeOut(duration: 0.6), value: value)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    var value: Double
    var icon: String
    var size: CGFloat = 60
    var lineWidth: CGFloat = 7

    var body: some View {
        ZStack {
            Circle()
                .stroke(DoplyColor.greenSoft, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(1, value)))
                .stroke(DoplyColor.green,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: value)
            Text(icon).font(.system(size: 19))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Section Title

struct SectionTitle: View {
    let text: String
    var topPadding: CGFloat = 22

    var body: some View {
        Text(text)
            .font(DoplyFont.display(17))
            .foregroundStyle(DoplyColor.ink)
            .padding(.top, topPadding)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Toast

@MainActor
final class ToastCenter: ObservableObject {
    @Published var message: String?
    private var task: Task<Void, Never>?

    func show(_ text: String) {
        message = text
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) { self.message = nil }
        }
    }
}

struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DoplyFont.body(12.5, .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(DoplyColor.ink, in: Capsule())
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Press Scale Button Style

struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
