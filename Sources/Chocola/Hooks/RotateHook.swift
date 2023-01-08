import Jinx
import UIKit

struct RotateHook: Hook {
    typealias T = @convention(c) (
        UIView,
        Selector
    ) -> Void

    let `class`: AnyClass? = objc_getClass("SBFWallpaperView") as? AnyClass
    let selector: Selector = #selector(UIView.layoutSubviews)
    let replacement: T = { target, cmd in
        let orig: T = PowPow.orig(RotateHook.self)!
        orig(target, cmd)
        
        Chocola.shared.layer.frame = target.layer.bounds
    }
}
