import Foundation
import CoreGraphics
import ObjectiveC

// MARK: - Cấu hình Profile màn hình iPad

struct iPadProfile {
    let key: String
    let name: String
    let groupDescription: String
    let physicalWidth: UInt32
    let physicalHeight: UInt32
    let logicalWidth: UInt32
    let logicalHeight: UInt32
    let sizeMm: CGSize
    let refreshRates: [Double]
}

let iPadProfiles: [iPadProfile] = [
    iPadProfile(
        key: "ipad-11",
        name: "iPad Pro 11\" (Gen 1-4)",
        groupDescription: "iPad Pro 11\" (M1, M2, 2018 - 2022) | 120Hz ProMotion",
        physicalWidth: 2388, physicalHeight: 1668,
        logicalWidth: 1194, logicalHeight: 834,
        sizeMm: CGSize(width: 237.0, height: 165.0),
        refreshRates: [120.0, 60.0]
    ),
    iPadProfile(
        key: "ipad-12-9",
        name: "iPad Pro 12.9\" (Gen 3-6)",
        groupDescription: "iPad Pro 12.9\" (M1, M2, Gen 3-6) | 120Hz ProMotion",
        physicalWidth: 2732, physicalHeight: 2048,
        logicalWidth: 1366, logicalHeight: 1024,
        sizeMm: CGSize(width: 262.0, height: 196.0),
        refreshRates: [120.0, 60.0]
    ),
    iPadProfile(
        key: "ipad-11-m4",
        name: "iPad Pro 11\" (M4)",
        groupDescription: "iPad Pro 11\" (M4 Tandem OLED) | 120Hz ProMotion",
        physicalWidth: 2420, physicalHeight: 1668,
        logicalWidth: 1210, logicalHeight: 834,
        sizeMm: CGSize(width: 237.0, height: 163.0),
        refreshRates: [120.0, 60.0]
    ),
    iPadProfile(
        key: "ipad-13-m4",
        name: "iPad Pro 13\" (M4)",
        groupDescription: "iPad Pro 13\" (M4 Tandem OLED) | 120Hz ProMotion",
        physicalWidth: 2752, physicalHeight: 2064,
        logicalWidth: 1376, logicalHeight: 1032,
        sizeMm: CGSize(width: 264.0, height: 198.0),
        refreshRates: [120.0, 60.0]
    ),
    iPadProfile(
        key: "ipad-10-9",
        name: "iPad Air / iPad 10.9\"",
        groupDescription: "iPad Air (Gen 4, 5 M1, M2 11\"), iPad Gen 10 | 60Hz",
        physicalWidth: 2360, physicalHeight: 1640,
        logicalWidth: 1180, logicalHeight: 820,
        sizeMm: CGSize(width: 236.0, height: 164.0),
        refreshRates: [60.0]
    ),
    iPadProfile(
        key: "ipad-air-13",
        name: "iPad Air 13\" (M2)",
        groupDescription: "iPad Air 13\" (M2) | 60Hz",
        physicalWidth: 2732, physicalHeight: 2048,
        logicalWidth: 1366, logicalHeight: 1024,
        sizeMm: CGSize(width: 262.0, height: 196.0),
        refreshRates: [60.0]
    ),
    iPadProfile(
        key: "ipad-10-2",
        name: "iPad 10.2\" (Gen 7-9)",
        groupDescription: "iPad Gen 7, 8, 9 (Retina 10.2\") | 60Hz",
        physicalWidth: 2160, physicalHeight: 1620,
        logicalWidth: 1080, logicalHeight: 810,
        sizeMm: CGSize(width: 207.0, height: 155.0),
        refreshRates: [60.0]
    ),
    iPadProfile(
        key: "ipad-mini",
        name: "iPad mini 8.3\"",
        groupDescription: "iPad mini (Gen 6, Gen 7) | 60Hz",
        physicalWidth: 2266, physicalHeight: 1488,
        logicalWidth: 1133, logicalHeight: 744,
        sizeMm: CGSize(width: 179.0, height: 117.0),
        refreshRates: [60.0]
    )
]

// MARK: - Quản lý Ghi nhớ Cấu hình Cuối (History Cache)

struct SavedConfig: Codable {
    let profileKey: String
    let deviceName: String?
}

class ConfigStore {
    private static var configURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".virtual_monitor_last_config.json")
    }

    static func save(profileKey: String, deviceName: String?) {
        let config = SavedConfig(profileKey: profileKey, deviceName: deviceName)
        if let data = try? JSONEncoder().encode(config) {
            try? data.write(to: configURL)
        }
    }

    static func load() -> SavedConfig? {
        guard let data = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(SavedConfig.self, from: data) else {
            return nil
        }
        return config
    }
}

// MARK: - Quản lý Sidecar Controller

class SidecarController {
    private var managerInstance: AnyObject?

    init() {
        dlopen("/System/Library/PrivateFrameworks/SidecarCore.framework/SidecarCore", RTLD_NOW)
        if let managerClass = NSClassFromString("SidecarDisplayManager") as? NSObject.Type {
            let sharedSel = NSSelectorFromString("sharedManager")
            if managerClass.responds(to: sharedSel) {
                self.managerInstance = managerClass.perform(sharedSel)?.takeUnretainedValue()
            }
        }
    }

    func discoverDevices() -> [NSObject] {
        guard let manager = managerInstance else { return [] }
        let selCandidates = ["devices", "connectedDevices", "compatibleDevices"]

        for selName in selCandidates {
            let sel = NSSelectorFromString(selName)
            if manager.responds(to: sel),
               let list = manager.perform(sel)?.takeUnretainedValue() as? [NSObject], !list.isEmpty {
                return list
            }
        }
        return []
    }

    func getDeviceName(_ device: NSObject) -> String {
        for key in ["name", "localizedName", "modelName"] {
            if let name = device.value(forKey: key) as? String, !name.isEmpty {
                return name
            }
        }
        return "Unknown iPad"
    }

    func connect(to device: NSObject) {
        let targetName = getDeviceName(device)
        print("🚀 Đang khởi tạo kết nối Sidecar tới: [\(targetName)]...")

        guard let manager = managerInstance else {
            fallbackConnectViaAppleScript(targetName: targetName)
            return
        }

        let sel = NSSelectorFromString("connectToDevice:completion:")
        if let method = class_getInstanceMethod(type(of: manager), sel) {
            typealias ConnectFunc = @convention(c) (AnyObject, Selector, AnyObject, @convention(block) (NSError?) -> Void) -> Void
            let imp = method_getImplementation(method)
            let function = unsafeBitCast(imp, to: ConnectFunc.self)

            let completionBlock: @convention(block) (NSError?) -> Void = { error in
                if let err = error {
                    print("⚠️ SidecarCore trả lời: \(err.localizedDescription).")
                    self.fallbackConnectViaAppleScript(targetName: targetName)
                } else {
                    print("✅ Kết nối Sidecar thành công qua SidecarCore!")
                }
            }

            function(manager, sel, device, completionBlock)
            return
        }

        fallbackConnectViaAppleScript(targetName: targetName)
    }

    private func fallbackConnectViaAppleScript(targetName: String) {
        print("🔄 Đang kích hoạt qua Display Notification...")
        let scriptSource = """
        tell application "System Events"
            tell process "ControlCenter"
                key code 53
            end tell
        end tell
        """
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: scriptSource) {
            appleScript.executeAndReturnError(&error)
        }
        print("👉 Vui lòng nhấp vào [Control Center] -> [Screen Mirroring] -> chọn [\(targetName)] nếu cần.")
    }
}

// MARK: - Trình tạo màn hình ảo vật lý

class HardwareVirtualMonitorManager {
    private var virtualDisplay: AnyObject?
    private let queue = DispatchQueue(label: "com.virtualdisplay.hardware.queue")

    func createDisplay(profile: iPadProfile) -> CGDirectDisplayID {
        guard let descriptorClass = NSClassFromString("CGVirtualDisplayDescriptor") as? NSObject.Type,
              let modeClass = NSClassFromString("CGVirtualDisplayMode") as? NSObject.Type,
              let settingsClass = NSClassFromString("CGVirtualDisplaySettings") as? NSObject.Type,
              let displayClass = NSClassFromString("CGVirtualDisplay") as? NSObject.Type else {
            print("❌ Lỗi: Hệ điều hành macOS không hỗ trợ CGVirtualDisplay API.")
            exit(1)
        }

        let descriptor = descriptorClass.init()
        descriptor.setValue("\(profile.name) (External)", forKey: "name")
        descriptor.setValue(profile.physicalWidth, forKey: "maxPixelsWide")
        descriptor.setValue(profile.physicalHeight, forKey: "maxPixelsHigh")
        descriptor.setValue(queue, forKey: "queue")
        descriptor.setValue(NSValue(size: profile.sizeMm), forKey: "sizeInMillimeters")
        descriptor.setValue(0x10AC, forKey: "vendorID")
        descriptor.setValue(0xD0A1, forKey: "productID")
        descriptor.setValue(0x20260901, forKey: "serialNum")

        let displayAlloc = displayClass.perform(NSSelectorFromString("alloc")).takeUnretainedValue()
        let displayInitSelector = NSSelectorFromString("initWithDescriptor:")
        guard displayAlloc.responds(to: displayInitSelector) else {
            print("❌ Lỗi: CGVirtualDisplay không hỗ trợ initWithDescriptor:")
            exit(1)
        }

        let displayInit = displayAlloc.perform(displayInitSelector, with: descriptor).takeUnretainedValue()
        self.virtualDisplay = displayInit

        var modes: [AnyObject] = []
        for rate in profile.refreshRates {
            modes.append(createMode(modeClass: modeClass, w: profile.physicalWidth, h: profile.physicalHeight, hz: rate))
            modes.append(createMode(modeClass: modeClass, w: profile.logicalWidth, h: profile.logicalHeight, hz: rate))
        }

        let settings = settingsClass.init()
        settings.setValue(modes, forKey: "modes")
        settings.setValue(1, forKey: "hiDPI")

        let applySelector = NSSelectorFromString("applySettings:")
        let altApplySelector = NSSelectorFromString("apply:")
        if displayInit.responds(to: applySelector) {
            _ = displayInit.perform(applySelector, with: settings)
        } else if displayInit.responds(to: altApplySelector) {
            _ = displayInit.perform(altApplySelector, with: settings)
        }

        let displayID = (displayInit.value(forKey: "displayID") as? CGDirectDisplayID) ?? 0
        setupDisplayArrangement(virtualID: displayID)

        let ratesStr = profile.refreshRates.map { "\(Int($0))Hz" }.joined(separator: ", ")
        print("\n=======================================================")
        print("  🎉 ĐÃ TẠO MÀN HÌNH VẬT LÝ NGOÀI THÀNH CÔNG!")
        print("  Model:           \(profile.name)")
        print("  Display ID:      \(displayID)")
        print("  Độ phân giải:    \(profile.physicalWidth) x \(profile.physicalHeight) (HiDPI: \(profile.logicalWidth) x \(profile.logicalHeight))")
        print("  Tần số quét:     \(ratesStr)")
        print("=======================================================")
        return displayID
    }

    private func setupDisplayArrangement(virtualID: CGDirectDisplayID) {
        guard virtualID != 0 else { return }
        var configRef: CGDisplayConfigRef?
        CGBeginDisplayConfiguration(&configRef)
        let mainBounds = CGDisplayBounds(CGMainDisplayID())
        CGConfigureDisplayOrigin(configRef, virtualID, Int32(mainBounds.width), 0)
        CGCompleteDisplayConfiguration(configRef, .permanently)
    }

    private func createMode(modeClass: NSObject.Type, w: UInt32, h: UInt32, hz: Double) -> AnyObject {
        let invoker = modeClass.perform(NSSelectorFromString("alloc")).takeUnretainedValue()
        let selector = NSSelectorFromString("initWithWidth:height:refreshRate:")
        let method = class_getInstanceMethod(modeClass, selector)!
        typealias ModeInitFunc = @convention(c) (AnyObject, Selector, UInt32, UInt32, Double) -> AnyObject
        let imp = method_getImplementation(method)
        let function = unsafeBitCast(imp, to: ModeInitFunc.self)
        return function(invoker, selector, w, h, hz)
    }
}

// MARK: - Điều hướng CLI & Menu Tương tác

func parseArguments() -> (iPadProfile?, String?, Bool) {
    let args = Array(CommandLine.arguments.dropFirst())
    var matchedProfile: iPadProfile?
    var targetDeviceName: String?
    var useLatest = false

    for arg in args {
        let clean = arg.replacingOccurrences(of: "--", with: "").replacingOccurrences(of: "-", with: "").lowercased()
        if clean == "latest" || clean == "lastest" || clean == "l" {
            useLatest = true
            continue
        }

        if arg.hasPrefix("-") {
            for p in iPadProfiles {
                let pClean = p.key.replacingOccurrences(of: "-", with: "").lowercased()
                if clean == pClean {
                    matchedProfile = p
                    break
                }
            }
        } else {
            targetDeviceName = arg.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    return (matchedProfile, targetDeviceName, useLatest)
}

func selectProfileInteractively() -> iPadProfile {
    print("\n=== BƯỚC 1: CHỌN PROFILE MÀN HÌNH IPAD ===")
    for (idx, p) in iPadProfiles.enumerated() {
        print(String(format: "[%d] --%-12@ : %@", idx + 1, p.key, p.groupDescription))
    }
    while true {
        print("👉 Nhập số (1 - \(iPadProfiles.count)): ", terminator: "")
        fflush(stdout)
        if let line = readLine(), let choice = Int(line.trimmingCharacters(in: .whitespacesAndNewlines)),
           choice >= 1 && choice <= iPadProfiles.count {
            return iPadProfiles[choice - 1]
        }
        print("⚠️ Lựa chọn không hợp lệ, vui lòng nhập lại!")
    }
}

func handleSidecarConnection(sidecar: SidecarController, targetDeviceName: String?) -> String? {
    print("\n📡 Đang quét thiết bị Sidecar trong phạm vi...")
    Thread.sleep(forTimeInterval: 1.0)
    let devices = sidecar.discoverDevices()

    guard !devices.isEmpty else {
        print("⚠️ Không tìm thấy iPad nào khả dụng gần đây.")
        return targetDeviceName
    }

    // 1. Tự động kết nối nếu có tên truyền vào
    if let target = targetDeviceName?.lowercased() {
        if let matched = devices.first(where: { sidecar.getDeviceName($0).lowercased().contains(target) }) {
            let actualName = sidecar.getDeviceName(matched)
            sidecar.connect(to: matched)
            return actualName
        } else {
            print("⚠️ Không tìm thấy iPad khớp tên '\(targetDeviceName!)'.")
        }
    }

    // 2. Hiện menu chọn nếu chưa có tên
    print("\n=== BƯỚC 2: CHỌN IPAD ĐỂ BẬT SIDECAR ===")
    for (idx, dev) in devices.enumerated() {
        print("[\(idx + 1)] \(sidecar.getDeviceName(dev))")
    }
    print("[0] Bỏ qua (không bật Sidecar)")

    while true {
        print("👉 Chọn thiết bị (0 - \(devices.count)): ", terminator: "")
        fflush(stdout)
        if let line = readLine(), let choice = Int(line.trimmingCharacters(in: .whitespacesAndNewlines)) {
            if choice == 0 { return nil }
            if choice >= 1 && choice <= devices.count {
                let chosenDevice = devices[choice - 1]
                let chosenName = sidecar.getDeviceName(chosenDevice)
                sidecar.connect(to: chosenDevice)
                return chosenName
            }
        }
        print("⚠️ Lựa chọn không hợp lệ, vui lòng thử lại!")
    }
}

// MARK: - Entry Point

var (cliProfile, cliDevice, useLatest) = parseArguments()

// Xử lý cờ --latest / --lastest / -l
if useLatest {
    if let saved = ConfigStore.load(),
       let matched = iPadProfiles.first(where: { $0.key == saved.profileKey }) {
        print("⚡️ Đang khôi phục cấu hình lần trước:")
        print("   - Màn hình: \(matched.name)")
        if let dev = saved.deviceName {
            print("   - Thiết bị iPad: \(dev)")
        }
        cliProfile = matched
        cliDevice = saved.deviceName
    } else {
        print("ℹ️ Chưa có lịch sử sử dụng nào được lưu. Chuyển về bước thiết lập ban đầu.")
    }
}

// Xác định profile màn hình
let selectedProfile = cliProfile ?? selectProfileInteractively()

// 1. Tạo màn hình ảo
let monitorManager = HardwareVirtualMonitorManager()
_ = monitorManager.createDisplay(profile: selectedProfile)

// 2. Kích hoạt Sidecar
let sidecar = SidecarController()
let connectedDeviceName = handleSidecarConnection(sidecar: sidecar, targetDeviceName: cliDevice)

// 3. Ghi nhớ cấu hình vừa dùng thành công
ConfigStore.save(profileKey: selectedProfile.key, deviceName: connectedDeviceName ?? cliDevice)

print("\n🚀 Tiến trình đang duy trì màn hình ảo. Nhấn Ctrl + C để thoát.")
RunLoop.main.run()
