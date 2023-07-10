//
//  SBProgressHUDTests.swift
//  SBProgressHUD-DemoTests
//
//  Created by JONO-Jsb on 2023/7/10.
//

@testable import SBProgressHUD
import XCTest

private func SBTestsProgressHUDVisible(_ progressHUD: SBProgressHUD, _ rootView: UIView?) {
    XCTAssertEqual(progressHUD.superview, rootView, "the HUD should be added to the view.")

    XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
    XCTAssertFalse(progressHUD.isHidden, "the HUD should be visible.")

    XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")
}

private func SBTestsProgressHUDHidden(_ progressHUD: SBProgressHUD, _ rootView: UIView?) {
    XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be faded out.")
}

private func SBTestsProgressHUDHiddenAndRemoved(_ progressHUD: SBProgressHUD, _ rootView: UIView?) {
    XCTAssertNil(progressHUD.superview, "the HUD should not have a superview.")
    XCTAssertNil(rootView?.subviews.first(where: { $0 == progressHUD }), "the HUD should not be part of the view hierarchy.")

    SBTestsProgressHUDHidden(progressHUD, rootView)
}

final class SBProgressHUDTests: XCTestCase {
    private var rootView: UIView?

    override func setUp() {
        super.setUp()

        let keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            // 部分情况下获取到的 activationState == .foregroundInactive，
            // 即场景处于前台但未接收事件 (A state that indicates that the scene is running in the foreground but is not receiving events.)
            // 这种情况通过调用 UIApplication.shared.windows.first(where: { $0.isKeyWindow }) 方法尝试再次获取
            // https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
            keyWindow = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }).flatMap { $0 as? UIWindowScene }.flatMap { $0.windows.first(where: { $0.isKeyWindow }) } ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        } else {
            keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }

        self.rootView = keyWindow?.rootViewController?.view
    }

    func testInitialize() {
        XCTAssertNotNil(SBProgressHUD())
    }
}
