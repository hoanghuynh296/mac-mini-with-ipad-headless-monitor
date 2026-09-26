# mac-mini-with-ipad-headless-monitor
This is simple code to use your iPad as main monitor via Sidecar for your Mac mini without any external screen setup. 
It's useful in case you wanna go out with your Mac mini and wanna use iPad as monitor for minimalist setup.

## Install

1. Download script
2. Build with
<code>swiftc -framework Foundation -framework CoreGraphics iPadMonitor.swift -o iPadMonitor</code>

## General invocation
<code>./iPadMonitor [DISPLAY_OPTION] [DEVICE_NAME]</code>

Ex: <code>./iPadMonitor --ipad-11 "My ipad"</code>

[DISPLAY_OPTION]:
| Option Flag | Hardware Group / Target Models | Physical Native | Logical HiDPI (@2x) | Aspect Ratio | Refresh Rates |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `--ipad-11` | iPad Pro 11-inch (Gen 1–4, M1, M2, A12X/Z) | 2388 × 1668 | 1194 × 834 | ~1.43:1 (4.3:3) | 120Hz, 60Hz |
| `--ipad-12-9` | iPad Pro 12.9-inch (Gen 3–6, M1, M2, A12X/Z) | 2732 × 2048 | 1366 × 1024 | 4:3 | 120Hz, 60Hz |
| `--ipad-11-m4` | iPad Pro 11-inch (M4 Ultra Retina Tandem OLED) | 2420 × 1668 | 1210 × 834 | ~1.45:1 | 120Hz, 60Hz |
| `--ipad-13-m4` | iPad Pro 13-inch (M4 Ultra Retina Tandem OLED) | 2752 × 2064 | 1376 × 1032 | 4:3 | 120Hz, 60Hz |
| `--ipad-10-9` | iPad Air (Gen 4, 5 M1, M2 11") & iPad (Gen 10) | 2360 × 1640 | 1180 × 820 | ~1.44:1 | 60Hz |
| `--ipad-air-13` | iPad Air 13-inch (M2) | 2732 × 2048 | 1366 × 1024 | 4:3 | 60Hz |
| `--ipad-10-2` | iPad 10.2-inch (Gen 7, 8, 9) | 2160 × 1620 | 1080 × 810 | 4:3 | 60Hz |
| `--ipad-mini` | iPad mini 8.3-inch (Gen 6, Gen 7 / A17 Pro) | 2266 × 1488 | 1133 × 744 | ~1.52:1 (3:2) | 60Hz |

## Use lastest session
<code>./iPadMonitor -l</code>
<code>./iPadMonitor -lastest</code>

## Interactive Mode (wizard-guided setup)
<code>./iPadMonitor</code>

## How to run this script without any external screen?
I have 2 options to recommend: 
1. Use <code>Automator</code> on Mac to run this script every time you logged in
2. Use <code>Terminus</code> app (or any terminal app) on iPad to connect to Mac via ssh

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
1. Use Automator to play a sound to notify each time you logged in success for better UX (you don't have monitor at this time to ensure you are logged)
1. Use usb c cable to connect iPad with Mac in first run to make sure sidecar working well (you can plug it out after connection is done)
2. If sidecar device not found, try to restart Mac / iPad or replug cable
