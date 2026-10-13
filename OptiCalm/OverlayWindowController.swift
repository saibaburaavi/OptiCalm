import AppKit

final class BreakWindow: NSWindow {
    var onDoubleEscape: (() -> Void)?
    private var lastEscapeAt: TimeInterval = 0
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            let now = ProcessInfo.processInfo.systemUptime
            if now - lastEscapeAt <= 1.0 { lastEscapeAt = 0; onDoubleEscape?() }
            else { lastEscapeAt = now }
            return
        }
        // Deliberately consume other keys so shortcuts do not reach the app behind the break.
    }
}

final class OverlayWindowController: NSWindowController {
    private let countdownLabel = NSTextField(labelWithString: "20")
    var onSkip: (() -> Void)?

    init(screen: NSScreen, isPrimary: Bool) {
        let window = BreakWindow(contentRect: screen.frame, styleMask: [.borderless], backing: .buffered, defer: false, screen: screen)
        super.init(window: window)
        window.setFrame(screen.frame, display: true)
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.backgroundColor = NSColor(calibratedWhite: 0.20, alpha: 0.90)
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.isReleasedWhenClosed = false
        window.onDoubleEscape = { [weak self] in self?.onSkip?() }

        let container = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
        container.autoresizingMask = [.width, .height]

        let eye = NSTextField(labelWithString: "◉")
        eye.font = .systemFont(ofSize: 54, weight: .medium)
        eye.textColor = .white
        eye.alignment = .center
        eye.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "Look 20 feet away")
        title.font = .systemFont(ofSize: 38, weight: .semibold)
        title.textColor = .white
        title.alignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        countdownLabel.font = .monospacedDigitSystemFont(ofSize: 76, weight: .bold)
        countdownLabel.textColor = .white
        countdownLabel.alignment = .center
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false

        let seconds = NSTextField(labelWithString: "seconds")
        seconds.font = .systemFont(ofSize: 24, weight: .regular)
        seconds.textColor = NSColor.white.withAlphaComponent(0.95)
        seconds.alignment = .center
        seconds.translatesAutoresizingMaskIntoConstraints = false

        let skipButton = NSButton(title: "Skip Break", target: self, action: #selector(skipBreak))
        skipButton.bezelStyle = .rounded
        skipButton.controlSize = .large
        skipButton.font = .systemFont(ofSize: 18, weight: .semibold)
        skipButton.keyEquivalent = ""
        skipButton.translatesAutoresizingMaskIntoConstraints = false

        let hint = NSTextField(labelWithString: "Press Esc twice to skip")
        hint.font = .systemFont(ofSize: 16)
        hint.textColor = NSColor.white.withAlphaComponent(0.82)
        hint.alignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false

        [eye, title, countdownLabel, seconds, skipButton, hint].forEach(container.addSubview)
        window.contentView = container
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -5),
            title.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            title.bottomAnchor.constraint(equalTo: countdownLabel.topAnchor, constant: -16),
            eye.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            eye.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -16),
            seconds.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            seconds.topAnchor.constraint(equalTo: countdownLabel.bottomAnchor, constant: -4),
            skipButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            skipButton.topAnchor.constraint(equalTo: seconds.bottomAnchor, constant: 28),
            skipButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            hint.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            hint.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 14)
        ])
        if isPrimary { window.makeKeyAndOrderFront(nil) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func skipBreak() { onSkip?() }
    func update(seconds: Int) { countdownLabel.stringValue = "\(seconds)" }
    override func showWindow(_ sender: Any?) { super.showWindow(sender); window?.orderFrontRegardless() }
}
