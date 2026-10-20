import SwiftUI

@MainActor
final class LockOverlay {
    private var windows: [NSWindow] = []

    func show(until endDate: Date, unlock: (() -> Void)?) {
        windows = NSScreen.screens.map { screen in
            let window = OverlayWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: LockOverlayView(endDate: endDate, unlock: unlock))
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
            return window
        }
        NSApp.activate(ignoringOtherApps: true)
        windows.first?.makeKey()
    }

    func hide() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}

private final class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
}

private struct LockOverlayView: View {
    let endDate: Date
    let unlock: (() -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "keyboard")
                .font(.system(size: 96, weight: .light))

            Text("Keyboard locked – cleaning in progress")
                .font(.system(size: 34, weight: .semibold))
                .multilineTextAlignment(.center)

            VStack(spacing: 6) {
                Text("Time remaining")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.6))
                Text(timerInterval: Date.now...endDate, countsDown: true)
                    .font(.system(size: 72, weight: .medium, design: .rounded).monospacedDigit())
            }

            if let unlock {
                Button(action: unlock) {
                    Text("Unlock")
                        .font(.title3.weight(.medium))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Text("The trackpad is locked too. Everything unlocks when the timer ends.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .foregroundStyle(.white)
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.88))
    }
}
