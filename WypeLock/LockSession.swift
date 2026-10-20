import Foundation

@MainActor
final class LockSession: ObservableObject {
    @Published private(set) var endDate: Date?

    private let blocker = InputBlocker()
    private let overlay = LockOverlay()
    private var unlockTask: Task<Void, Error>?

    var isLocked: Bool { endDate != nil }

    func lock() {
        guard !isLocked else { return }

        let blocksTrackpad = Preferences.blocksTrackpad
        guard AccessibilityPermission.isGranted, blocker.start(blockingTrackpad: blocksTrackpad) else {
            AccessibilityPermission.request()
            SettingsWindow.show()
            return
        }

        let duration = Preferences.lockDuration
        let endDate = Date.now.addingTimeInterval(duration)
        self.endDate = endDate
        overlay.show(until: endDate, unlock: blocksTrackpad ? nil : { [weak self] in self?.unlock() })

        unlockTask = Task { [weak self] in
            try await Task.sleep(for: .seconds(duration))
            self?.unlock()
        }
    }

    func unlock() {
        unlockTask?.cancel()
        unlockTask = nil
        blocker.stop()
        overlay.hide()
        endDate = nil
    }
}
