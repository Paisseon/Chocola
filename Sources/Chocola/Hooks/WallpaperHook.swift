import Jinx
import UIKit

struct WallpaperHook: Hook {
    typealias T = @convention(c) (
        UIViewController,
        Selector
    ) -> Void

    let `class`: AnyClass? = objc_getClass("SBWWallpaperViewController") as? AnyClass
    let selector: Selector = #selector(UIViewController.viewDidLoad)
    let replacement: T = { target, cmd in
        let orig: T = PowPow.orig(WallpaperHook.self)!
        orig(target, cmd)
        
        Chocola.shared.setWallpaper(on: target.view.layer.bounds)
        target.view.layer.addSublayer(Chocola.shared.layer)
    }
}
