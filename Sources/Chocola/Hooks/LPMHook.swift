import Foundation
import Jinx

struct LPMHook: Hook {
    typealias T = @convention(c) (
        AnyObject,
        Selector
    ) -> Bool

    let `class`: AnyClass? = ProcessInfo.self
    let selector: Selector = #selector(getter: ProcessInfo.isLowPowerModeEnabled)
    let replacement: T = { target, cmd in
        let orig: T = PowPow.orig(LPMHook.self)!
        let origVal: Bool = orig(target, cmd)
        
        Chocola.shared.isLowPower = origVal
        origVal ? Chocola.shared.pause() : Chocola.shared.play()
        
        return origVal
    }
}
