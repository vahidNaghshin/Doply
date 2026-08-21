import SwiftUI
import UIKit

struct WalkSessionView: View {
    @EnvironmentObject private var store: DoplyStore
    @EnvironmentObject private var toast: ToastCenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @StateObject private var manager = WalkSessionManager()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DoplyColor.skyTop, DoplyColor.cream],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            if manager.isMotionAccessDenied {
                MotionAccessDeniedView(onCancel: cancelWalk, onOpenSettings: openSettings)
            } else {
                sessionContent
            }
        }
        .onAppear { manager.start() }
    }

    private var sessionContent: some View {
        VStack(spacing: 22) {
            VStack(spacing: 4) {
                Text("🚶 Walk Session")
                    .font(DoplyFont.display(20))
                    .foregroundStyle(DoplyColor.headerInk)
                Text("Keep your phone with you while you move")
                    .font(DoplyFont.body(12.5, .semibold))
                    .foregroundStyle(DoplyColor.headerSub)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            Spacer(minLength: 0)

            DoplyCard {
                VStack(spacing: 18) {
                    VStack(spacing: 4) {
                        Text("\(manager.steps)")
                            .font(DoplyFont.display(58, .black))
                            .foregroundStyle(DoplyColor.greenDark)
                            .contentTransition(.numericText())
                            .animation(.easeOut(duration: 0.25), value: manager.steps)
                        Text("steps this walk")
                            .font(DoplyFont.body(13, .semibold))
                            .foregroundStyle(DoplyColor.inkSoft)
                    }
                    .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(DoplyColor.greenSoft)
                        .frame(height: 1)

                    HStack(spacing: 0) {
                        WalkStat(icon: "⏱️", value: elapsedLabel, label: "Time")
                        Rectangle().fill(DoplyColor.greenSoft).frame(width: 1).padding(.vertical, 4)
                        WalkStat(icon: "📍", value: distanceLabel, label: "Distance")
                        Rectangle().fill(DoplyColor.greenSoft).frame(width: 1).padding(.vertical, 4)
                        WalkStat(icon: "🪙", value: "+\(coinsEarned(forSteps: manager.steps))", label: "So far")
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Button(action: finishWalk) {
                    HStack(spacing: 10) {
                        Text("🏁")
                            .font(.system(size: 18))
                        Text("Finish Walk")
                            .font(DoplyFont.display(15))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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

                Button("Cancel", action: cancelWalk)
                    .font(DoplyFont.body(13.5, .bold))
                    .foregroundStyle(DoplyColor.inkSoft)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 30)
    }

    private var elapsedLabel: String {
        let m = manager.elapsedSeconds / 60
        let s = manager.elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var distanceLabel: String {
        String(format: "%.2f km", manager.distanceMeters / 1000)
    }

    private func finishWalk() {
        manager.stop()
        let earned = coinsEarned(forSteps: manager.steps)
        store.steps += manager.steps
        store.coins += earned
        toast.show("Nice walk! +\(earned) 🪙 earned")
        dismiss()
    }

    private func cancelWalk() {
        manager.stop()
        dismiss()
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

private struct WalkStat: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(icon).font(.system(size: 16))
            Text(value)
                .font(DoplyFont.display(14))
                .foregroundStyle(DoplyColor.ink)
            Text(label)
                .font(DoplyFont.body(10, .semibold))
                .foregroundStyle(DoplyColor.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MotionAccessDeniedView: View {
    let onCancel: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text("🔒")
                .font(.system(size: 44))
                .frame(width: 92, height: 92)
                .background(.white, in: Circle())
                .shadowSm()

            VStack(spacing: 8) {
                Text("Motion Access Needed")
                    .font(DoplyFont.display(18))
                    .foregroundStyle(DoplyColor.headerInk)
                Text("Doply needs Motion & Fitness access to count your steps during a walk. Enable it in Settings to start moving.")
                    .font(DoplyFont.body(13, .semibold))
                    .foregroundStyle(DoplyColor.headerSub)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onOpenSettings) {
                    Text("Open Settings")
                        .font(DoplyFont.display(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DoplyColor.green, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(PressScaleStyle())

                Button("Cancel", action: onCancel)
                    .font(DoplyFont.body(13.5, .bold))
                    .foregroundStyle(DoplyColor.inkSoft)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    WalkSessionView()
        .environmentObject(DoplyStore())
        .environmentObject(ToastCenter())
}
