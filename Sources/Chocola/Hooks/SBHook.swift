import Foundation
import Jinx

struct SBHook: Hook {
    typealias T = @convention(c) (
        AnyObject,
        Selector,
        Any?
    ) -> Void

    let `class`: AnyClass? = objc_getClass("SpringBoard") as? AnyClass
    let selector: Selector = sel_registerName("frontDisplayDidChange:")
    let replacement: T = { target, cmd, app in
        let orig: T = PowPow.orig(SBHook.self)!
        orig(target, cmd, app)
        
        Chocola.shared.isInApp = app != nil
        app != nil ? Chocola.shared.pause() : Chocola.shared.play()
    }
}
