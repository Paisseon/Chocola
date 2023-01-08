import CoreFoundation
import Jinx

struct Tweak {
    static func ctor() {
        let prefs: Preferences = .shared

        guard prefs.isEnabled,
              access("/var/mobile/Library/Preferences/emt.paisseon.chocola/wallpaper-VID.mp4", F_OK) == 0
        else {
            return
        }

        BacklightHook().hook()
        BlurHook().hook()
        LPMHook().hook(onlyIf: prefs.isLowPower)
        RotateHook().hook()
        SBHook().hook()
        WallpaperHook().hook()
    }
}

@_cdecl("jinx_entry")
func jinx_entry() {
    Tweak.ctor()
}
