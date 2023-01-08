import mryipc

// MARK: - _Preferences

private struct _Preferences {
    // MARK: Lifecycle

    init() {
        let domain: CFString = "emt.paisseon.chocola" as CFString

        if NSHomeDirectory() == "/var/mobile" {
            let keyList: CFArray = CFPreferencesCopyKeyList(
                domain,
                kCFPreferencesCurrentUser,
                kCFPreferencesAnyHost
            ) ?? [] as CFArray

            dict = CFPreferencesCopyMultiple(
                keyList,
                domain,
                kCFPreferencesCurrentUser,
                kCFPreferencesAnyHost
            ) as? [String: Any] ?? [:]
        } else {
            let center: MRYIPCCenter = .init(named: "lilliana.jinx.ipc")

            dict = center.callExternalMethod(
                sel_registerName("preferencesFor:"),
                withArguments: "emt.paisseon.chocola"
            ) as? [String: Any] ?? [:]
        }
    }

    // MARK: Internal

    func get<T>(
        for key: String,
        default val: T
    ) -> T {
        dict[key] as? T ?? val
    }

    // MARK: Private

    private let dict: [String: Any]
}

// MARK: - Preferences

final class Preferences {
    // MARK: Lifecycle

    private init() {
        let truePrefs: _Preferences = .init()

        isEnabled = truePrefs.get(for: "isEnabled", default: true)
        isLowPower = truePrefs.get(for: "isLowPower", default: true)
        isCaffeinated = truePrefs.get(for: "isCaffeinated", default: false)
        isMuted = truePrefs.get(for: "isMuted", default: false)
    }

    // MARK: Internal

    static let shared: Preferences = .init()

    let isCaffeinated: Bool
    let isEnabled: Bool
    let isLowPower: Bool
    let isMuted: Bool
}
