//
//  SBProgressHUDTests.swift
//
//  Created by Max on 2023/7/13
//
//  Copyright © 2023 Max. All rights reserved.
//

@testable import SBProgressHUD
import XCTest

final class SBProgressHUDTests: XCTestCase {
    private var rootView: UIView?

    private var screenAccuracy: CGFloat!
    private var safeAreaInsets: UIEdgeInsets!

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

        self.screenAccuracy = 1.0 / UIScreen.main.scale
        self.safeAreaInsets = keyWindow?.safeAreaInsets ?? .zero
    }

    func testProgress() {
        let progressHUD = SBProgressHUD()
        progressHUD.style = .linearProgress
        progressHUD.progress = 0.2

        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progress, 0.2)

        progressHUD.progress = 0.4

        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progress, 0.4)

        progressHUD.progress = 0.6

        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progress, 0.6)
    }

    func testProgressObject() {
        let progressObject = Progress(totalUnitCount: 100)

        let progressHUD = SBProgressHUD()
        progressHUD.style = .linearProgress
        progressHUD.progressObject = progressObject

        let firstProgressObjectTestingExpectation = self.expectation(description: "the HUD progressObject testing should be finished.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            progressObject.becomeCurrent(withPendingUnitCount: 20)
            progressObject.resignCurrent()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progress, 0.2)

                firstProgressObjectTestingExpectation.fulfill()
            }
        }

        let secondProgressObjectTestingExpectation = self.expectation(description: "the HUD progressObject testing should be finished.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            progressObject.becomeCurrent(withPendingUnitCount: 20)
            progressObject.resignCurrent()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progress, 0.4)

                secondProgressObjectTestingExpectation.fulfill()
            }
        }

        let thirdProgressObjectTestingExpectation = self.expectation(description: "the HUD progressObject testing should be finished.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            progressObject.becomeCurrent(withPendingUnitCount: 20)
            progressObject.resignCurrent()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progress, 0.6)

                thirdProgressObjectTestingExpectation.fulfill()
            }
        }

        self.wait(for: [firstProgressObjectTestingExpectation, secondProgressObjectTestingExpectation, thirdProgressObjectTestingExpectation], timeout: 5.0)
    }

    func testColor() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: false)
        progressHUD.style = .activityIndicator
        progressHUD.color = UIColor.red

        XCTAssertEqual(self.getSubview(withType: UIActivityIndicatorView.self, in: progressHUD)?.color, UIColor.red)
        XCTAssertEqual(progressHUD.titleLabel.textColor, UIColor.red)
        XCTAssertEqual(progressHUD.detailsLabel.textColor, UIColor.red)

        progressHUD.style = .linearProgress
        progressHUD.color = UIColor.green

        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.trackTintColor, UIColor.clear)
        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progressTintColor, UIColor.green)
        XCTAssertEqual(progressHUD.titleLabel.textColor, UIColor.green)
        XCTAssertEqual(progressHUD.detailsLabel.textColor, UIColor.green)

        class CustomView: UIView {}

        let customView = CustomView()

        progressHUD.style = .customView
        progressHUD.color = UIColor.blue
        progressHUD.customView = customView

        XCTAssertEqual(self.getSubview(withType: CustomView.self, in: progressHUD)?.tintColor, UIColor.blue)
        XCTAssertEqual(progressHUD.titleLabel.textColor, UIColor.blue)
        XCTAssertEqual(progressHUD.detailsLabel.textColor, UIColor.blue)

        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [SBProgressHUD.self]).color = UIColor.cyan

        progressHUD.style = .activityIndicator
        progressHUD.color = UIColor.red

        XCTAssertEqual(self.getSubview(withType: UIActivityIndicatorView.self, in: progressHUD)?.color, UIColor.cyan)
        XCTAssertEqual(progressHUD.titleLabel.textColor, UIColor.red)
        XCTAssertEqual(progressHUD.detailsLabel.textColor, UIColor.red)

        SBProgressContainerView.appearance(whenContainedInInstancesOf: [SBProgressHUD.self]).trackTintColor = UIColor.yellow
        SBProgressContainerView.appearance(whenContainedInInstancesOf: [SBProgressHUD.self]).progressTintColor = UIColor.magenta

        progressHUD.style = .linearProgress
        progressHUD.color = UIColor.green

        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.trackTintColor, UIColor.yellow)
        XCTAssertEqual(self.getSubview(withType: SBProgressContainerView.self, in: progressHUD)?.progressTintColor, UIColor.magenta)
        XCTAssertEqual(progressHUD.titleLabel.textColor, UIColor.green)
        XCTAssertEqual(progressHUD.detailsLabel.textColor, UIColor.green)

        SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false)
    }

    func testLayout() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: false)

        // left/up
        progressHUD.offset = UIOffset(horizontal: -.greatestFiniteMagnitude, vertical: -.greatestFiniteMagnitude)
        progressHUD.margin = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 0.0, right: 0.0)

        progressHUD.setNeedsLayout()
        progressHUD.layoutIfNeeded()

        XCTAssertEqual(progressHUD.bezelView.frame.minX, self.safeAreaInsets.left + 10.0, accuracy: self.screenAccuracy)
        XCTAssertEqual(progressHUD.bezelView.frame.minY, self.safeAreaInsets.top + 10.0, accuracy: self.screenAccuracy)

        // right/up
        progressHUD.offset = UIOffset(horizontal: .greatestFiniteMagnitude, vertical: -.greatestFiniteMagnitude)
        progressHUD.margin = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 10.0)

        progressHUD.setNeedsLayout()
        progressHUD.layoutIfNeeded()

        XCTAssertEqual(progressHUD.bezelView.frame.maxX, self.rootView!.bounds.width - self.safeAreaInsets.right - 10.0, accuracy: self.screenAccuracy)
        XCTAssertEqual(progressHUD.bezelView.frame.minY, self.safeAreaInsets.top + 10.0, accuracy: self.screenAccuracy)

        // left/down
        progressHUD.offset = UIOffset(horizontal: -.greatestFiniteMagnitude, vertical: .greatestFiniteMagnitude)
        progressHUD.margin = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 10.0, right: 0.0)

        progressHUD.setNeedsLayout()
        progressHUD.layoutIfNeeded()

        XCTAssertEqual(progressHUD.bezelView.frame.minX, self.safeAreaInsets.left + 10.0, accuracy: self.screenAccuracy)
        XCTAssertEqual(progressHUD.bezelView.frame.maxY, self.rootView!.bounds.height - self.safeAreaInsets.bottom - 10.0, accuracy: self.screenAccuracy)

        // right/down
        progressHUD.offset = UIOffset(horizontal: .greatestFiniteMagnitude, vertical: .greatestFiniteMagnitude)
        progressHUD.margin = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 10.0)

        progressHUD.setNeedsLayout()
        progressHUD.layoutIfNeeded()

        XCTAssertEqual(progressHUD.bezelView.frame.maxX, self.rootView!.bounds.width - self.safeAreaInsets.right - 10.0, accuracy: self.screenAccuracy)
        XCTAssertEqual(progressHUD.bezelView.frame.maxY, self.rootView!.bounds.height - self.safeAreaInsets.bottom - 10.0, accuracy: self.screenAccuracy)

        // minimum size
        progressHUD.minimumSize = CGSize(width: 50.0, height: 100.0)

        progressHUD.setNeedsLayout()
        progressHUD.layoutIfNeeded()

        XCTAssertNotEqual(progressHUD.bezelView.bounds.size.width, 50.0, accuracy: self.screenAccuracy)
        XCTAssertEqual(progressHUD.bezelView.bounds.size.height, 100.0, accuracy: self.screenAccuracy)

        // content margin
        progressHUD.minimumSize = .zero
        progressHUD.contentMargin = UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0)

        progressHUD.setNeedsLayout()
        progressHUD.layoutIfNeeded()

        XCTAssertGreaterThanOrEqual(progressHUD.bezelView.bounds.size.width, 100.0)
        XCTAssertGreaterThanOrEqual(progressHUD.bezelView.bounds.size.height, 100.0)

        SBProgressHUD.hideProgressHUD(fromView: self.rootView, animated: false)
    }

    func testGracePeriod() {
        let completionExpectation = self.expectation(description: "the HUD completion callback should have been called.")

        let progressHUD = SBProgressHUD()
        progressHUD.gracePeriod = 2.0
        progressHUD.removeFromSuperviewWhenStopped = true

        progressHUD.completion = {
            completionExpectation.fulfill()
        }

        self.rootView?.addSubview(progressHUD)

        progressHUD.showProgressHUD(animated: true)

        XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

            XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

            XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

            progressHUD.hideProgressHUD(animated: false)
        }

        self.wait(for: [completionExpectation], timeout: 5.0)
    }

    func testHideBeforeGracePeriodElapsed() {
        let completionExpectation = self.expectation(description: "the HUD completion callback should have been called.")

        let progressHUD = SBProgressHUD()
        progressHUD.gracePeriod = 2.0
        progressHUD.removeFromSuperviewWhenStopped = true

        progressHUD.completion = {
            completionExpectation.fulfill()
        }

        self.rootView?.addSubview(progressHUD)

        progressHUD.showProgressHUD(animated: true)

        XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

            XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

            progressHUD.hideProgressHUD(animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

            XCTAssertNil(progressHUD.superview, "the HUD should not have a superview.")
        }

        self.wait(for: [completionExpectation], timeout: 5.0)
    }

    func testMinimumDisplayingTime() {
        let completionExpectation = self.expectation(description: "the HUD completion callback should have been called.")

        let progressHUD = SBProgressHUD()
        progressHUD.minimumDisplayingTime = 2.0
        progressHUD.removeFromSuperviewWhenStopped = true

        progressHUD.completion = {
            completionExpectation.fulfill()
        }

        self.rootView?.addSubview(progressHUD)

        progressHUD.showProgressHUD(animated: true)

        XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        progressHUD.hideProgressHUD(animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

            XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden")
            XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden")

            XCTAssertNil(progressHUD.superview, "the HUD should not have a superview.")
        }

        self.wait(for: [completionExpectation], timeout: 5.0)
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

    func testDelayHide() {
        let progressHUD = SBProgressHUD.showProgressHUD(onView: self.rootView, animated: false)

        XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        progressHUD.delayHideProgressHUD(2.0, animated: false)

        XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        let delayHideExpectation = self.expectation(description: "the HUD should have been delay hidden.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden")
            XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden")

            XCTAssertNil(progressHUD.superview, "the HUD should not have a superview.")

            delayHideExpectation.fulfill()
        }

        self.wait(for: [delayHideExpectation], timeout: 5.0)
    }

    func testMultipleTimeParametersVie() {
        let completionExpectation = self.expectation(description: "the HUD completion callback should have been called.")

        let progressHUD = SBProgressHUD()
        progressHUD.gracePeriod = 2.0
        progressHUD.minimumDisplayingTime = 5.0
        progressHUD.removeFromSuperviewWhenStopped = true

        progressHUD.completion = {
            completionExpectation.fulfill()
        }

        self.rootView?.addSubview(progressHUD)

        progressHUD.showProgressHUD(animated: true)

        XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        progressHUD.delayHideProgressHUD(3.0, animated: false)

        XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
        XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
        XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

        XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

            XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            XCTAssertEqual(progressHUD.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 1.0, "the HUD should be visible.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 1.0, "the HUD should be visible.")

            XCTAssertEqual(progressHUD.superview, self.rootView, "the HUD should be added to the view.")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            XCTAssertEqual(progressHUD.alpha, 0.0, "the HUD should be hidden.")
            XCTAssertEqual(progressHUD.backgroundView.alpha, 0.0, "the HUD backgroundView should be hidden.")
            XCTAssertEqual(progressHUD.bezelView.alpha, 0.0, "the HUD bezelView should be hidden.")

            XCTAssertNil(progressHUD.superview, "the HUD should not have a superview.")
        }

        self.wait(for: [completionExpectation], timeout: 8.0)
    }

    private func getSubview<T>(withType type: T.Type, in view: UIView) -> T? {
        var result: T? = nil

        for subview in view.subviews {
            if subview is T {
                result = subview as! T
                break
            }

            result = self.getSubview(withType: type, in: subview)
            if result != nil {
                break
            }
        }

        return result
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
