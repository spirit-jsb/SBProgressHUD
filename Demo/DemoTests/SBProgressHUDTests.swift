//
//  SBProgressHUDTests.swift
//  SBProgressHUD-DemoTests
//
//  Created by JONO-Jsb on 2023/7/10.
//

@testable import SBProgressHUD
import XCTest

final class SBProgressHUDTests: XCTestCase {
    private var rootView: UIView?

    private var progress: Float!
    private var progressObject = Progress(totalUnitCount: 100)

    private var hideExpectation: XCTestExpectation?

    override func setUp() {
        super.setUp()

        let keyWindow: UIWindow?
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        } else {
            keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        }

        self.rootView = keyWindow?.rootViewController?.view

        self.progress = 0.0
        self.progressObject.completedUnitCount = 0
    }

    func testProgress() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: true)
        progressHUD.style = .linearProgress

        let updatingProgressValueTimer = CADisplayLink(target: self, selector: #selector(self.updateProgress))
        updatingProgressValueTimer.add(to: .current, forMode: .default)

        let testingProgressTimer = Timer(timeInterval: 0.1, repeats: true) { [unowned self] _ in
            progressHUD.progress = self.progress
        }
        RunLoop.current.add(testingProgressTimer, forMode: .default)

        let testingProgressExpectation = self.expectation(description: "the HUD progress testing should be finished.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            updatingProgressValueTimer.invalidate()

            testingProgressTimer.invalidate()

            testingProgressExpectation.fulfill()
        }

        self.wait(for: [testingProgressExpectation], timeout: 5.0)

        SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false)
    }

    func testProgressObject() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: true)
        progressHUD.style = .doughnutProgress

        let updatingProgressValueTimer = CADisplayLink(target: self, selector: #selector(self.updateProgress))
        updatingProgressValueTimer.add(to: .current, forMode: .default)

        let testingProgressObjectTimer = Timer(timeInterval: 0.1, repeats: true) { [unowned self] _ in
            progressHUD.progressObject = self.progressObject
        }
        RunLoop.current.add(testingProgressObjectTimer, forMode: .default)

        let testingProgressExpectation = self.expectation(description: "the HUD progress testing should be finished.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            updatingProgressValueTimer.invalidate()

            testingProgressObjectTimer.invalidate()

            testingProgressExpectation.fulfill()
        }

        self.wait(for: [testingProgressExpectation], timeout: 5.0)

        SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false)
    }

    func testNonAnimatedConvenienceHUD() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: false)

        XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        XCTAssertEqual(SBProgressHUD.getProgressHUD(fromView: self.rootView), progressHUD, "the HUD should be found via the convenience operation.")

        XCTAssertNotEqual(progressHUD.backgroundView.layer.animationKeys()?.contains("opacity"), true, "the opacity should NOT be animated in backgroundView")
        XCTAssertNotEqual(progressHUD.bezelView.layer.animationKeys()?.contains("opacity"), true, "the opacity should NOT be animated in bezelView")

        XCTAssertTrue(SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false), "the HUD should be found and removed.")

        XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden")
        XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden")

        XCTAssertNil(progressHUD.superview, "the HUD should not have a superview.")

        XCTAssertNotEqual(progressHUD.backgroundView.layer.animationKeys()?.contains("opacity"), true, "the opacity should NOT be animated in backgroundView")
        XCTAssertNotEqual(progressHUD.bezelView.layer.animationKeys()?.contains("opacity"), true, "the opacity should NOT be animated in bezelView")

        XCTAssertFalse(SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false), "a subsequent HUD hide operation should fail.")
    }

    func testAnimatedConvenienceHUD() {
        self.hideExpectation = self.expectation(description: "the hideProgressHUD: delegate should have been called.")

        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: true)
        progressHUD.delegate = self

        XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        XCTAssertEqual(SBProgressHUD.getProgressHUD(fromView: self.rootView), progressHUD, "the HUD should be found via the convenience operation.")

        XCTAssertEqual(progressHUD.backgroundView.layer.animationKeys()?.contains("opacity"), true, "the opacity should be animated in backgroundView")
        XCTAssertEqual(progressHUD.bezelView.layer.animationKeys()?.contains("opacity"), true, "the opacity should be animated in bezelView")

        XCTAssertTrue(SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: true), "the HUD should be found and removed.")

        XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should still be visible")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden")
        XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should still be part of the view hierarchy")

        XCTAssertEqual(progressHUD.backgroundView.layer.animationKeys()?.contains("opacity"), true, "the opacity should be animated in backgroundView")
        XCTAssertEqual(progressHUD.bezelView.layer.animationKeys()?.contains("opacity"), true, "the opacity should be animated in bezelView")

        self.wait(for: [self.hideExpectation!], timeout: 5.0)
    }

    @objc
    private func updateProgress() {
        if self.progress > 1.0 {
            self.progress = 0.0
        }

        if self.progressObject.completedUnitCount > 100 {
            self.progressObject.completedUnitCount = 0
        }

        self.progress += 0.01
        self.progressObject.completedUnitCount += 1
    }
}

extension SBProgressHUDTests: SBProgressHUDDelegate {
    func hideProgressHUD(_ progressHUD: SBProgressHUD) {
        XCTAssertEqual(progressHUD.alpha, 0.0, "the hud should be hidden")

        XCTAssertNil(progressHUD.superview, "the hud should be not have a superview")

        XCTAssertFalse(SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false), "a subsequent HUD hide operation should fail.")

        self.hideExpectation?.fulfill()
    }
}
