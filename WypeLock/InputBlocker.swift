import AppKit

final class InputBlocker {
    private static let keyboardEvents: [NSEvent.EventType] = [.keyDown, .keyUp, .flagsChanged, .systemDefined]

    private static let trackpadEvents: [NSEvent.EventType] = [
        .mouseMoved, .scrollWheel,
        .leftMouseDown, .leftMouseUp, .leftMouseDragged,
        .rightMouseDown, .rightMouseUp, .rightMouseDragged,
        .otherMouseDown, .otherMouseUp, .otherMouseDragged,
        .gesture, .magnify, .swipe, .rotate, .beginGesture, .endGesture, .smartMagnify, .pressure,
    ]

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func start(blockingTrackpad: Bool) -> Bool {
        guard tap == nil else { return true }

        let blockedEvents = blockingTrackpad ? Self.keyboardEvents + Self.trackpadEvents : Self.keyboardEvents
        let mask = blockedEvents.reduce(CGEventMask(0)) { $0 | NSEvent.EventTypeMask(type: $1).rawValue }

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, blocker in
                guard type == .tapDisabledByTimeout || type == .tapDisabledByUserInput else { return nil }
                if let blocker {
                    Unmanaged<InputBlocker>.fromOpaque(blocker).takeUnretainedValue().reenable()
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return false }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        self.tap = tap
        runLoopSource = source
        return true
    }

    func stop() {
        guard let tap else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CFMachPortInvalidate(tap)
        self.tap = nil
        runLoopSource = nil
    }

    private func reenable() {
        guard let tap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    deinit {
        stop()
    }
}
