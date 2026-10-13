import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let breakManager = BreakManager()
    private var statusItem: NSStatusItem!
    private var pauseItem: NSMenuItem!
    private var loginItem: NSMenuItem!
    private var latestMenuTitle = "20:00"

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()
        enableLaunchAtLoginOnFirstRun()
        updateLoginMenu()
        breakManager.onStatusChange = { [weak self] text, paused in
            DispatchQueue.main.async {
                guard let self else { return }
                self.latestMenuTitle = self.menuBarTitle(from: text)
                self.refreshStatusButton()
                self.pauseItem.title = paused ? "Resume" : "Pause"
            }
        }
        breakManager.start()
    }

    private func menuBarTitle(from status: String) -> String {
        if status.hasPrefix("Break: ") { return status.replacingOccurrences(of: "Break: ", with: "") }
        return status
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.toolTip = "OptiCalm"
        refreshStatusButton()

        let menu = NSMenu()
        add("Start Break Now", #selector(startBreakNow), "b", to: menu)
        pauseItem = add("Pause", #selector(togglePause), "p", to: menu)
        add("Pause for 30 Minutes", #selector(pause30), "", to: menu)
        add("Pause for 60 Minutes", #selector(pause60), "", to: menu)
        add("Reset 20-Minute Timer", #selector(resetTimer), "r", to: menu)
        menu.addItem(.separator())
        loginItem = add("Launch at Login", #selector(toggleLaunchAtLogin), "", to: menu)
        menu.addItem(.separator())
        add("About OptiCalm", #selector(showAbout), "", to: menu)
        add("Quit OptiCalm", #selector(quitApp), "q", to: menu)
        statusItem.menu = menu
    }

    private func refreshStatusButton() {
        guard let button = statusItem?.button else { return }
        button.title = " \(latestMenuTitle)"
        if let icon = NSImage(named: "OptiCalmMenuEye") {
            icon.isTemplate = true
            icon.size = NSSize(width: 22, height: 22)
            button.image = icon
            button.imagePosition = .imageLeading
        }
    }

    @discardableResult private func add(_ title: String, _ action: Selector, _ key: String, to menu: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
        return item
    }

    private func enableLaunchAtLoginOnFirstRun() {
        let key = "OptiCalmDidConfigureLaunchAtLogin"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        do { try SMAppService.mainApp.register() }
        catch { NSLog("Could not enable Launch at Login: %@", error.localizedDescription) }
        UserDefaults.standard.set(true, forKey: key)
    }

    private func updateLoginMenu() { loginItem?.state = SMAppService.mainApp.status == .enabled ? .on : .off }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
            else { try SMAppService.mainApp.register() }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Launch at Login"
            alert.informativeText = "macOS could not change the login setting. You can also manage it in System Settings > General > Login Items.\n\n\(error.localizedDescription)"
            alert.runModal()
        }
        updateLoginMenu()
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "OptiCalm"
        alert.informativeText = """
OptiCalm is a simple 20-20-20 eye-break reminder for macOS designed to help you take regular visual breaks during screen use.

HOW IT WORKS
• Counts down 20 minutes in the menu bar.
• At the end of the timer, grays all connected displays for a 20-second break.
• Reminds you to look about 20 feet away during the break.
• Shows a 20-second countdown on the break screen.

BREAK CONTROLS
• Click Skip Break to end a break immediately.
• Press Escape twice to skip a break.
• Start Break Now begins a break at any time.
• Pause temporarily stops the work timer until you resume it.
• Pause for 30 Minutes or Pause for 60 Minutes resumes automatically when the selected time expires.
• Reset 20-Minute Timer starts a fresh 20-minute countdown.

OTHER FEATURES
• Supports the Mac display and multiple external monitors.
• Launch at Login can start OptiCalm automatically when you sign in.
• A manual Pause is cleared when OptiCalm is relaunched, so a new launch starts with a fresh timer.

OptiCalm runs locally on your Mac and is designed to stay out of the way until it is time for a break.
"""
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func startBreakNow() { breakManager.startBreakNow() }
    @objc private func togglePause() { breakManager.togglePause() }
    @objc private func pause30() { breakManager.pause(for: 30 * 60) }
    @objc private func pause60() { breakManager.pause(for: 60 * 60) }
    @objc private func resetTimer() { breakManager.resetWorkTimer() }
    @objc private func quitApp() { NSApp.terminate(nil) }
}
