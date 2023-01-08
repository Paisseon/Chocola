import Jinx
import UIKit

struct BlurHook: Hook {
    typealias T = @convention(c) (
        UIView,
        Selector
    ) -> Void

    let `class`: AnyClass? = objc_getClass("_SBWFakeBlurView") as? AnyClass
    let selector: Selector = #selector(UIView.didMoveToWindow)
    let replacement: T = { target, cmd in
        let orig: T = PowPow.orig(BlurHook.self)!
        orig(target, cmd)
        
        target.layer.addSublayer(Chocola.shared.layer2)
    }
}
