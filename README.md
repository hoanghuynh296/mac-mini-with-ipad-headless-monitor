# mac-mini-with-ipad-headless-monitor
This is simple code to use your iPad as main monitor via Sidecar for your Mac mini without any external screen setup

# Install

1. Download script
2. Build with
<code>swiftc -framework Foundation -framework CoreGraphics iPadMonitor.swift -o iPadMonitor</code>

# General invocation
<code>./iPadMonitor [DISPLAY_OPTION] [DEVICE_NAME]</code>

# Use lastest session
<code>./iPadMonitor -l</code>
<code>./iPadMonitor -lastest</code>

# Interactive Mode (wizard-guided setup)
<code>./iPadMonitor</code>
