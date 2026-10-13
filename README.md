# OptiCalm

**OptiCalm** is a lightweight macOS menu-bar application designed to encourage regular eye breaks using the **20-20-20 rule**.

Every 20 minutes, OptiCalm gently reminds you to look away from your screen for 20 seconds.

## Features

- Live countdown to the next break directly in the macOS menu bar
- Automatic 20-second break every 20 minutes
- Grays all connected displays during a break
- Supports Mac displays and multiple external monitors
- On-screen **Skip Break** button
- Double-press **Esc** to skip a break
- Pause indefinitely or pause for **30** or **60 minutes**
- Start a break manually at any time
- Reset the 20-minute countdown
- Optional **Launch at Login**
- Lightweight and runs entirely on your Mac

## Installation

### Download OptiCalm

You do **not** need Xcode to use OptiCalm.

1. Go to the **Releases** section of this repository.
2. Open the latest OptiCalm release.
3. Download **`OptiCalm-1.0.zip`** under **Assets**.
4. Unzip the downloaded file.
5. Drag **OptiCalm.app** into your **Applications** folder.
6. Open OptiCalm from Applications.

OptiCalm will appear in your macOS menu bar.

### macOS security notice

OptiCalm 1.0 is currently distributed without Apple notarization.

On first launch, macOS may prevent the application from opening.

If this happens:

1. Open **System Settings → Privacy & Security**.
2. Scroll to the Security section.
3. Locate the message regarding OptiCalm.
4. Select **Open Anyway**, if available.
5. Confirm that you want to open OptiCalm.

There is no need to disable Gatekeeper.

## Using OptiCalm

The menu-bar countdown shows how much time remains until your next eye break.

By default:

**20 minutes of screen time → 20-second eye break → repeat**

During a break, OptiCalm grays your displays and shows a countdown.

You can complete the break normally, click **Skip Break**, or press **Esc twice** to return to work immediately.

The menu also provides options to:

- Start Break Now
- Pause / Resume
- Pause for 30 Minutes
- Pause for 60 Minutes
- Reset the 20-Minute Timer
- Launch at Login

## 20-20-20 Rule

The 20-20-20 rule is a commonly used approach for taking regular breaks from prolonged screen viewing:

> Every 20 minutes, look at something approximately 20 feet away for at least 20 seconds.

OptiCalm provides the timing and screen reminder so you don't have to keep track of it yourself.

## Build from Source

OptiCalm is a native macOS application written in Swift.

Developers who want to inspect, modify, or build the application can clone this repository and open:

`OptiCalm.xcodeproj`

in Xcode.

Xcode is **not required** for users installing OptiCalm from a GitHub Release.

## Version

**OptiCalm 1.0**

## Disclaimer

OptiCalm is a screen-break reminder and is not medical software or a substitute for professional eye-care advice.
