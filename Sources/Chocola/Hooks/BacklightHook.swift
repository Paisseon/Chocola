import Foundation
import Jinx

struct BacklightHook: Hook {
    typealias T = @convention(c) (
        AnyObject,
        Selector,
        Double,
        Int64
    ) -> Void

    let `class`: AnyClass? = objc_getClass("SBBacklightController") as? AnyClass
    let selector: Selector = sel_registerName("_notifyObserversDidAnimateToFactor:source:")
    let replacement: T = { target, cmd, factor, source in
        let orig: T = PowPow.orig(BacklightHook.self)!
        orig(target, cmd, factor, source)
        
        factor == 0.0 ? Chocola.shared.pause() : Chocola.shared.play()
    }
}
