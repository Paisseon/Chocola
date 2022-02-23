import Cephei

class Preferences {
	static let shared = Preferences() // shared instance so we can check these values from the chocola class
	
	private let preferences            = HBPreferences(identifier: "emt.paisseon.chocola")
	private(set) var enabled: ObjCBool = true
	
	private init() { // various cephei stuff
		preferences.register(defaults: [
			"enabled" : true,
		])
	
		preferences.register(_Bool: &enabled, default: true, forKey: "enabled")
	}
}
