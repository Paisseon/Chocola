import Cephei

final class Preferences {
	static let shared = Preferences()
	
	private let preferences     = HBPreferences(identifier: "emt.paisseon.chocola")
    
	private(set) var enabled    = true
	private(set) var homescreen = false
	private(set) var lockscreen = false
	private(set) var mute       = false
	private(set) var sync       = false
	private(set) var lpmPause   = false
    private(set) var caffeine   = false
    
    private var enabledI    : ObjCBool = true
    private var homescreenI : ObjCBool = false
    private var lockscreenI : ObjCBool = false
    private var muteI       : ObjCBool = false
    private var syncI       : ObjCBool = false
    private var lpmPauseI   : ObjCBool = false
    private var caffeineI   : ObjCBool = false
	
	private init() {
		preferences.register(defaults: [
			"enabled"    : true,
			"homescreen" : false,
			"lockscreen" : false,
			"mute"       : false,
			"sync"       : false,
			"lpmPause"   : false,
            "caffeine"   : false,
		])
	
		preferences.register(_Bool: &enabledI,    default: true,  forKey: "enabled")
		preferences.register(_Bool: &homescreenI, default: false, forKey: "homescreen")
		preferences.register(_Bool: &lockscreenI, default: false, forKey: "lockscreen")
		preferences.register(_Bool: &muteI,       default: false, forKey: "mute")
		preferences.register(_Bool: &syncI,       default: false, forKey: "sync")
		preferences.register(_Bool: &lpmPauseI,   default: false, forKey: "lpmPause")
        preferences.register(_Bool: &caffeineI,   default: false, forKey: "caffeine")
        
        enabled    = enabledI.boolValue
        homescreen = homescreenI.boolValue
        lockscreen = lockscreenI.boolValue
        mute       = muteI.boolValue
        sync       = syncI.boolValue
        lpmPause   = lpmPauseI.boolValue
        caffeine   = caffeineI.boolValue
	}
}
