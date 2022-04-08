import Cephei

class Preferences {
	static let shared = Preferences()
	
	private let preferences               = HBPreferences(identifier: "emt.paisseon.chocola")
	private(set) var enabled: ObjCBool    = true
	private(set) var homescreen: ObjCBool = false
	private(set) var lockscreen: ObjCBool = false
	private(set) var mute: ObjCBool       = true
	private(set) var sync: ObjCBool       = true
	private(set) var lpmPause: ObjCBool   = true
	
	private init() { // various cephei stuff
		preferences.register(defaults: [
			"enabled"    : true,
			"homescreen" : false,
			"lockscreen" : false,
			"mute"       : true,
			"sync"       : true,
			"lpmPause"   : true,
		])
	
		preferences.register(_Bool: &enabled, default: true, forKey: "enabled")
		preferences.register(_Bool: &homescreen, default: false, forKey: "homescreen")
		preferences.register(_Bool: &lockscreen, default: false, forKey: "lockscreen")
		preferences.register(_Bool: &mute, default: true, forKey: "mute")
		preferences.register(_Bool: &sync, default: true, forKey: "sync")
		preferences.register(_Bool: &lpmPause, default: true, forKey: "lpmPause")
	}
}
