import AppKit

final class BreakManager {
    private let workDuration: TimeInterval = 20 * 60
    private let breakDuration: TimeInterval = 20
    private var remainingWork: TimeInterval = 20 * 60
    private var remainingBreak: TimeInterval = 20
    private var timer: Timer?
    private var overlays: [OverlayWindowController] = []
    private(set) var isPaused = false
    private var pauseUntil: Date?
    private var isOnBreak = false

    var onStatusChange: ((String, Bool) -> Void)?

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        publishStatus()
    }

    @objc private func tick() {
        if isPaused {
            if let pauseUntil, Date() >= pauseUntil { resume() }
            else { publishStatus(); return }
        }
        if isOnBreak {
            remainingBreak -= 1
            updateOverlayCountdown()
            if remainingBreak <= 0 { finishBreak() }
        } else {
            remainingWork -= 1
            if remainingWork <= 0 { beginBreak() }
        }
        publishStatus()
    }

    func startBreakNow() { if !isOnBreak { beginBreak() } }

    func togglePause() {
        if isPaused { resume() }
        else { isPaused = true; pauseUntil = nil; publishStatus() }
    }

    func pause(for duration: TimeInterval) {
        if isOnBreak { dismissBreak() }
        isPaused = true
        pauseUntil = Date().addingTimeInterval(duration)
        publishStatus()
    }

    private func resume() {
        isPaused = false
        pauseUntil = nil
        publishStatus()
    }

    func resetWorkTimer() {
        if isOnBreak { dismissBreak() }
        isPaused = false
        pauseUntil = nil
        remainingWork = workDuration
        publishStatus()
    }

    func dismissBreak() { if isOnBreak { finishBreak() } }

    private func beginBreak() {
        isPaused = false
        pauseUntil = nil
        isOnBreak = true
        remainingBreak = breakDuration
        createOverlays()
        updateOverlayCountdown()
    }

    private func finishBreak() {
        overlays.forEach { $0.close() }
        overlays.removeAll()
        isOnBreak = false
        remainingBreak = breakDuration
        remainingWork = workDuration
        publishStatus()
    }

    private func createOverlays() {
        overlays.forEach { $0.close() }
        overlays = NSScreen.screens.map { screen in
            let controller = OverlayWindowController(screen: screen, isPrimary: screen == NSScreen.main)
            controller.onSkip = { [weak self] in self?.dismissBreak() }
            controller.showWindow(nil)
            return controller
        }
    }

    @objc private func screensChanged() {
        if isOnBreak { createOverlays(); updateOverlayCountdown() }
    }

    private func updateOverlayCountdown() {
        let seconds = max(0, Int(ceil(remainingBreak)))
        overlays.forEach { $0.update(seconds: seconds) }
    }

    private func publishStatus() {
        let text: String
        if isPaused {
            if let pauseUntil {
                let seconds = max(0, Int(ceil(pauseUntil.timeIntervalSinceNow)))
                text = String(format: "Paused %02d:%02d", seconds / 60, seconds % 60)
            } else { text = "Paused" }
        } else if isOnBreak {
            text = "Break: \(Int(max(0, remainingBreak)))s"
        } else {
            let total = Int(max(0, remainingWork))
            text = String(format: "%02d:%02d", total / 60, total % 60)
        }
        onStatusChange?(text, isPaused)
    }
}
