# mac-mini-with-ipad-headless-monitor
This is simple code to use your iPad as main monitor via Sidecar for your Mac mini without any external screen setup. 
It's useful in case you wanna go out with your Mac mini and wanna use iPad as monitor for minimalist setup.

## Install

1. Download script
2. Build with
<code>swiftc -framework Foundation -framework CoreGraphics iPadMonitor.swift -o iPadMonitor</code>

## General invocation
<code>./iPadMonitor [DISPLAY_OPTION] [DEVICE_NAME]</code>

## Use lastest session
<code>./iPadMonitor -l</code>
<code>./iPadMonitor -lastest</code>

## Interactive Mode (wizard-guided setup)
<code>./iPadMonitor</code>

## How to run this script without any external screen?
I have 2 options to recommend: 
1. use <code>Automator</code> on Mac to run this script every time you logged in
2. use <code>Terminus</code> app (or any terminal app) on iPad to connect to Mac via ssh

### Use <code>Automator</code>
Please ask AI or Google search, I don't place it here to avoid duplicate content :D 

### Use <code>Terminus</code>
1. Download <code>Terminus</code> app on iPad to connect to Mac via ssh
2. Plug type C cable from iPad to Mac
3. Open <code>Terminus</code> and connect to Mac 
<img width="1194" height="834" alt="IMG_2278" src="https://github.com/user-attachments/assets/bc43fc1c-fa92-4104-8a46-e37a55b287fb" />
<img width="1194" height="834" alt="IMG_2279" src="https://github.com/user-attachments/assets/e3a08563-320c-4410-8fb3-fcc847de769d" />
<img width="1194" height="834" alt="IMG_2280" src="https://github.com/user-attachments/assets/8616f1f6-e6e5-4e64-b1da-c451fffff5c6" />
<img width="1194" height="834" alt="IMG_2281" src="https://github.com/user-attachments/assets/e75f1ab3-aab5-41fa-a81c-22e524ff3691" />
4. Run command line above and enjoy the coffee shop
   
# Pro tips: 
1. use Automator to play a sound to notify each time you logged in success for better UX (you don't have monitor at this time to ensure you are logged)
1. Use usb c cable to connect iPad with Mac in first run to make sure sidecar working well (you can plug it out after connection is done)
2. If sidecar device not found, try to restart Mac / iPad or replug cable
