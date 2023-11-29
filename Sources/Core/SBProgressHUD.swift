//
//  SBProgressHUD.swift
//
//  Created by Max on 2023/7/13
//
//  Copyright © 2023 Max. All rights reserved.
//

#if canImport(UIKit)

import UIKit

@objc
public protocol SBProgressHUDDelegate: NSObjectProtocol {
    @objc
    optional func hideProgressHUD(_ progressHUD: SBProgressHUD)
}

public class SBProgressHUD: UIView {
    public enum Style {
        case activityIndicator
        case linearProgress
        case doughnutProgress
        case pieProgress
        case textLabel
        case customView
    }

    public enum AnimationType {
        case fade
        case zoom
        case zoomOut
        case zoomIn
    }

    public weak var delegate: SBProgressHUDDelegate?

    public var completion: (() -> Void)?

    public var style: Style {
        didSet {
            if oldValue != self.style {
                self.updateProgressHUD()
            }
        }
    }

    public var animationType: AnimationType

    public var progress: Float {
        didSet {
            if oldValue != self.progress {
                self.updateProgress()
            }
        }
    }

    public var progressObject: Progress? {
        didSet {
            if oldValue != self.progressObject {
                self.resetObservingProgressValueChangedTimer(true)
            }
        }
    }

    public var color: UIColor? {
        didSet {
            if oldValue != self.color {
                self.updateColor()
            }
        }
    }

    public var backgroundViewColor: UIColor? {
        willSet {
            if newValue != self.backgroundViewColor {
                self.backgroundView.color = newValue
            }
        }
    }

    public var bezelViewBlurEffectStyle: UIBlurEffect.Style? {
        willSet {
            if newValue != nil, newValue != self.bezelViewBlurEffectStyle {
                self.bezelView.blurEffectStyle = newValue!
            }
        }
    }

    public var titleText: String? {
        willSet {
            if newValue != self.titleText {
                self.titleLabel.text = newValue
            }
        }
    }

    public var titleFont: UIFont {
        willSet {
            if newValue != self.titleFont {
                self.titleLabel.font = newValue
            }
        }
    }

    public var titleTextColor: UIColor? {
        willSet {
            if newValue != self.titleTextColor {
                self.titleLabel.textColor = newValue ?? self.color
            }
        }
    }

    public var titleAttributedText: NSAttributedString? {
        willSet {
            if newValue != self.titleAttributedText {
                self.titleLabel.attributedText = newValue
            }
        }
    }

    public var detailsText: String? {
        willSet {
            if newValue != self.detailsText {
                self.detailsLabel.text = newValue
            }
        }
    }

    public var detailsFont: UIFont {
        willSet {
            if newValue != self.detailsFont {
                self.detailsLabel.font = newValue
            }
        }
    }

    public var detailsTextColor: UIColor? {
        willSet {
            if newValue != self.detailsTextColor {
                self.detailsLabel.textColor = newValue ?? self.color
            }
        }
    }

    public var detailsAttributedText: NSAttributedString? {
        willSet {
            if newValue != self.detailsAttributedText {
                self.detailsLabel.attributedText = newValue
            }
        }
    }

    /// specify amount to offset a position, positive for right or down, negative for left or up
    public var offset: UIOffset {
        willSet {
            if newValue != self.offset {
                self.setNeedsUpdateConstraints()
            }
        }
    }

    public var margin: UIEdgeInsets {
        willSet {
            if newValue != self.margin {
                self.setNeedsUpdateConstraints()
            }
        }
    }

    public var minimumSize: CGSize {
        willSet {
            if newValue != self.minimumSize {
                self.setNeedsUpdateConstraints()
            }
        }
    }

    public var contentMargin: UIEdgeInsets {
        willSet {
            if newValue != self.contentMargin {
                self.setNeedsUpdateConstraints()
            }
        }
    }

    public var gracePeriod: TimeInterval
    public var minimumDisplayingTime: TimeInterval

    public var removeFromSuperviewWhenStopped: Bool

    public var enabledMotionEffects: Bool {
        didSet {
            if oldValue != self.enabledMotionEffects {
                self.resetMotionEffects()
            }
        }
    }

    public var customView: UIView? {
        didSet {
            if oldValue != self.customView {
                if self.style == .customView {
                    self.updateProgressHUD()
                }
            }
        }
    }

    lazy var backgroundView: SBBackgroundContainerView = {
        let containerView = SBBackgroundContainerView(style: .solidColor)
        containerView.color = .clear

        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.alpha = 0.0

        return containerView
    }()

    lazy var bezelView: SBBackgroundContainerView = {
        let containerView = SBBackgroundContainerView(style: .blur)

        containerView.alpha = 0.0
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.layer.cornerRadius = 5.0
        if #available(iOS 13.0, *) {
            containerView.layer.cornerCurve = .continuous
        }

        return containerView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.titleFont
        label.textColor = self.titleTextColor ?? self.color
        label.textAlignment = .center

        label.backgroundColor = .clear
        label.isOpaque = false
        label.translatesAutoresizingMaskIntoConstraints = false

        label.setContentCompressionResistancePriority(.init(rawValue: 998.0), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(rawValue: 998.0), for: .vertical)

        return label
    }()

    lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.font = self.detailsFont
        label.textColor = self.detailsTextColor ?? self.color
        label.textAlignment = .center
        label.numberOfLines = 0

        label.backgroundColor = .clear
        label.isOpaque = false
        label.translatesAutoresizingMaskIntoConstraints = false

        label.setContentCompressionResistancePriority(.init(rawValue: 998.0), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(rawValue: 998.0), for: .vertical)

        return label
    }()

    private static let contentSpacing: CGFloat = 6.0

    private var isActivity: Bool = false
    private var prepareHidden: Bool = false

    private var isUsingAnimation: Bool = true

    private var bezelConstraints = [NSLayoutConstraint]()
    private var contentSpacingConstraints = [NSLayoutConstraint]()

    private lazy var topSpacerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var bottomSpacerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var indicatorView: UIView?

    private var latestActivityTime: Date?

    private var gracePeriodTimer: Timer?
    private var minimumDisplayingTimer: Timer?
    private var delayHideTimer: Timer?

    private var observingProgressValueChangedTimer: CADisplayLink? {
        didSet {
            if oldValue != self.observingProgressValueChangedTimer {
                self.observingProgressValueChangedTimer?.add(to: .main, forMode: .default)
            }
        }
    }

    private var motionEffectGroup: UIMotionEffectGroup?

    public init() {
        self.style = .activityIndicator
        self.animationType = .fade

        self.progress = 0.0
        self.progressObject = nil

        if #available(iOS 13.0, *) {
            self.color = UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? UIColor(white: 0.15, alpha: 1.0) : UIColor(white: 0.95, alpha: 1.0) })
        } else {
            self.color = UIColor(white: 0.15, alpha: 1.0)
        }

        self.titleFont = UIFont.boldSystemFont(ofSize: 16.0)

        self.detailsFont = UIFont.boldSystemFont(ofSize: 12.0)

        self.offset = UIOffset.zero
        self.margin = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        self.minimumSize = CGSize.zero

        self.contentMargin = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

        self.gracePeriod = 0.0
        self.minimumDisplayingTime = 0.0

        self.removeFromSuperviewWhenStopped = false

        self.enabledMotionEffects = false

        super.init(frame: .zero)

        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.backgroundColor = UIColor.clear
        self.alpha = 0.0
        self.isOpaque = false

        self.layer.allowsGroupOpacity = false

        self.constructViewHierarchy()

        self.updateProgressHUD()

        self.addObservers()
    }

    @available(*, unavailable)
    override public init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToSuperview() {
        self.updateOrientation()
    }

    override public func layoutSubviews() {
        if !self.needsUpdateConstraints() {
            self.updateContentSpacingConstraints()
        }

        super.layoutSubviews()
    }

    override public func updateConstraints() {
        defer {
            super.updateConstraints()
        }

        var bezelConstraints = [NSLayoutConstraint]()
        var contentSpacingConstraints = [NSLayoutConstraint]()

        // 获取 bezel contentViews
        var bezelContentViews: [UIView] = [self.topSpacerView, self.titleLabel, self.detailsLabel, self.bottomSpacerView]
        if let indicator = self.indicatorView, indicator.superview == self.bezelView {
            bezelContentViews.insert(indicator, at: 1)
        }

        // 移除现有约束
        NSLayoutConstraint.deactivate(self.constraints)

        if !self.bezelConstraints.isEmpty {
            NSLayoutConstraint.deactivate(self.bezelConstraints)
        }

        NSLayoutConstraint.deactivate(self.topSpacerView.constraints)
        NSLayoutConstraint.deactivate(self.bottomSpacerView.constraints)

        // 获取 safeAreaInsets
        let safeAreaInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeAreaInsets = self.safeAreaInsets
        } else {
            safeAreaInsets = UIEdgeInsets.zero
        }

        // bezel centering
        var bezelCenteringConstraints = [NSLayoutConstraint]()
        bezelCenteringConstraints.append(self.bezelView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: self.offset.horizontal))
        bezelCenteringConstraints.append(self.bezelView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: self.offset.vertical))

        self.updatePriority(.init(rawValue: 997.0), constraints: bezelCenteringConstraints)

        NSLayoutConstraint.activate(bezelCenteringConstraints)

        // bezel margin
        var bezelMarginConstraints = [NSLayoutConstraint]()
        bezelMarginConstraints.append(self.bezelView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: abs(self.margin.left) + safeAreaInsets.left))
        bezelMarginConstraints.append(self.bezelView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: abs(self.margin.top) + safeAreaInsets.top))
        bezelMarginConstraints.append(self.bezelView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -abs(self.margin.right) - safeAreaInsets.right))
        bezelMarginConstraints.append(self.bezelView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -abs(self.margin.bottom) - safeAreaInsets.bottom))

        self.updatePriority(.init(rawValue: 998.0), constraints: bezelMarginConstraints)

        NSLayoutConstraint.activate(bezelMarginConstraints)

        // bezel minimum size
        if self.minimumSize != .zero {
            var bezelMinimumSizeConstraints = [NSLayoutConstraint]()
            bezelMinimumSizeConstraints.append(self.bezelView.widthAnchor.constraint(greaterThanOrEqualToConstant: self.minimumSize.width))
            bezelMinimumSizeConstraints.append(self.bezelView.heightAnchor.constraint(greaterThanOrEqualToConstant: self.minimumSize.height))

            self.updatePriority(.init(rawValue: 999.0), constraints: bezelMinimumSizeConstraints)

            bezelConstraints.append(contentsOf: bezelMinimumSizeConstraints)
        }

        // top & bottom spacer height
        self.topSpacerView.addConstraint(self.topSpacerView.heightAnchor.constraint(greaterThanOrEqualToConstant: abs(self.contentMargin.top)))
        self.bottomSpacerView.addConstraint(self.bottomSpacerView.heightAnchor.constraint(greaterThanOrEqualToConstant: abs(self.contentMargin.bottom)))

        // top & bottom spacer height should be equal
        bezelConstraints.append(self.topSpacerView.heightAnchor.constraint(equalTo: self.bottomSpacerView.heightAnchor))

        // bezel content layout
        bezelContentViews.enumerated().forEach { index, bezelContentView in
            bezelConstraints.append(bezelContentView.centerXAnchor.constraint(equalTo: self.bezelView.centerXAnchor))

            bezelConstraints.append(bezelContentView.leadingAnchor.constraint(greaterThanOrEqualTo: self.bezelView.leadingAnchor, constant: abs(self.contentMargin.left)))
            bezelConstraints.append(bezelContentView.leadingAnchor.constraint(lessThanOrEqualTo: self.bezelView.trailingAnchor, constant: -abs(self.contentMargin.right)))

            if index == 0 {
                bezelConstraints.append(bezelContentView.topAnchor.constraint(equalTo: self.bezelView.topAnchor))
            } else if index == bezelContentViews.count - 1 {
                bezelConstraints.append(bezelContentView.bottomAnchor.constraint(equalTo: self.bezelView.bottomAnchor))
            }

            if index > 0 {
                let contentSpacingConstraint = bezelContentView.topAnchor.constraint(equalTo: bezelContentViews[index - 1].bottomAnchor)

                bezelConstraints.append(contentSpacingConstraint)
                contentSpacingConstraints.append(contentSpacingConstraint)
            }
        }

        self.bezelConstraints = bezelConstraints
        NSLayoutConstraint.activate(bezelConstraints)

        self.contentSpacingConstraints = contentSpacingConstraints
        self.updateContentSpacingConstraints()
    }

    deinit {
        self.removeObservers()
    }

    public static func showProgressHUD(onView view: UIView?, animated: Bool) -> SBProgressHUD {
        let progressHUD = SBProgressHUD()
        progressHUD.removeFromSuperviewWhenStopped = true

        view?.addSubview(progressHUD)

        progressHUD.showProgressHUD(animated: animated)

        return progressHUD
    }

    @discardableResult
    public static func hideProgressHUD(fromView view: UIView?, animated: Bool) -> Bool {
        guard let progressHUD = SBProgressHUD.getProgressHUD(fromView: view) else {
            return false
        }
        progressHUD.removeFromSuperviewWhenStopped = true

        progressHUD.hideProgressHUD(animated: animated)

        return true
    }

    public static func getProgressHUD(fromView view: UIView?) -> SBProgressHUD? {
        guard let view = view else {
            return nil
        }

        for subview in view.subviews.reversed() {
            if subview is SBProgressHUD {
                let progressHUD = subview as! SBProgressHUD
                if progressHUD.isActivity && !progressHUD.prepareHidden {
                    return progressHUD
                }
            }
        }

        return nil
    }

    public func showProgressHUD(animated: Bool) {
        // cancel gracePeriod timer
        self.gracePeriodTimer?.invalidate()

        self.isActivity = true
        self.prepareHidden = false

        self.isUsingAnimation = animated

        // handle gracePeriod timer
        if self.gracePeriod > 0.0 {
            let gracePeriodTimer = Timer(timeInterval: self.gracePeriod, target: self, selector: #selector(self.handleGracePeriodTimer(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(gracePeriodTimer, forMode: .common)

            self.gracePeriodTimer = gracePeriodTimer

            return
        }

        self.showUsingAnimation(animated)
    }

    public func hideProgressHUD(animated: Bool) {
        // cancel gracePeriod timer
        self.gracePeriodTimer?.invalidate()

        // cancel minimumDisplaying timer
        self.minimumDisplayingTimer?.invalidate()

        self.isActivity = false

        self.isUsingAnimation = animated

        // handle gracePeriod timer
        if self.minimumDisplayingTime > 0.0 && self.latestActivityTime != nil {
            let timeInterval = Date().timeIntervalSince(self.latestActivityTime!)

            if timeInterval < self.minimumDisplayingTime {
                let minimumDisplayingTimer = Timer(timeInterval: self.minimumDisplayingTime - timeInterval, target: self, selector: #selector(self.handleMinimumDisplayingTimer(_:)), userInfo: nil, repeats: false)
                RunLoop.current.add(minimumDisplayingTimer, forMode: .common)

                self.minimumDisplayingTimer = minimumDisplayingTimer

                return
            }
        }

        self.hideUsingAnimation(animated)
    }

    public func delayHideProgressHUD(_ delay: TimeInterval, animated: Bool) {
        // cancel hideDelay timer
        self.delayHideTimer?.invalidate()

        self.prepareHidden = true

        let delayHideTimer = Timer(timeInterval: delay, target: self, selector: #selector(self.handleDelayHideTimer(_:)), userInfo: animated, repeats: false)
        RunLoop.current.add(delayHideTimer, forMode: .common)

        self.delayHideTimer = delayHideTimer
    }

    private func constructViewHierarchy() {
        self.bezelView.addSubview(self.topSpacerView)
        self.bezelView.addSubview(self.titleLabel)
        self.bezelView.addSubview(self.detailsLabel)
        self.bezelView.addSubview(self.bottomSpacerView)

        self.addSubview(self.bezelView)
        self.addSubview(self.backgroundView)
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeStatusBarOrientation(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }

    private func showUsingAnimation(_ animated: Bool) {
        // cancel gracePeriod timer
        self.gracePeriodTimer?.invalidate()

        // remove all animations
        self.backgroundView.layer.removeAllAnimations()
        self.bezelView.layer.removeAllAnimations()

        self.latestActivityTime = Date()

        self.alpha = 1.0

        self.resetObservingProgressValueChangedTimer(true)

        self.resetMotionEffects()

        if animated {
            self.animate(withAnimationType: self.animationType, isActivity: true, completion: nil)
        } else {
            self.backgroundView.alpha = 1.0
            self.bezelView.alpha = 1.0
        }
    }

    private func hideUsingAnimation(_ animated: Bool) {
        // cancel minimumDisplaying timer
        self.minimumDisplayingTimer?.invalidate()
        // cancel delayHide timer
        self.delayHideTimer?.invalidate()

        if animated && self.latestActivityTime != nil {
            self.latestActivityTime = nil

            self.animate(withAnimationType: self.animationType, isActivity: false, completion: { [weak self] _ in
                self?.finished()
            })
        } else {
            self.latestActivityTime = nil

            self.backgroundView.alpha = 0.0
            self.bezelView.alpha = 0.0

            self.finished()
        }
    }

    private func animate(withAnimationType animationType: AnimationType, isActivity: Bool, completion: ((Bool) -> Void)?) {
        // automatically determine the correct zoom animation type
        var animationType = animationType
        if animationType == .zoom {
            animationType = isActivity ? .zoomIn : .zoomOut
        }

        let minimumScale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let maximumScale = CGAffineTransform(scaleX: 1.5, y: 1.5)

        // starting state
        if animationType == .zoomIn, isActivity, self.bezelView.alpha == 0.0 {
            self.bezelView.transform = minimumScale
        } else if animationType == .zoomOut, isActivity, self.bezelView.alpha == 0.0 {
            self.bezelView.transform = maximumScale
        }

        // perform animations
        let animations = {
            if isActivity {
                self.bezelView.transform = .identity
            } else if animationType == .zoomIn, !isActivity {
                self.bezelView.transform = maximumScale
            } else if animationType == .zoomOut, !isActivity {
                self.bezelView.transform = minimumScale
            }

            self.backgroundView.alpha = isActivity ? 1.0 : 0.0
            self.bezelView.alpha = isActivity ? 1.0 : 0.0
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.beginFromCurrentState], animations: animations, completion: completion)
    }

    private func finished() {
        // disabled progress observing
        self.resetObservingProgressValueChangedTimer(false)

        if !self.isActivity {
            self.alpha = 0.0

            if self.removeFromSuperviewWhenStopped {
                self.removeFromSuperview()
            }
        }

        if let completion = self.completion {
            completion()
        }

        if let delegate = self.delegate, delegate.responds(to: #selector(SBProgressHUDDelegate.hideProgressHUD(_:))) {
            delegate.perform(#selector(SBProgressHUDDelegate.hideProgressHUD(_:)), with: self)
        }
    }

    private func updateOrientation() {
        // 与父视图保持一致
        if let superview = self.superview {
            self.frame = superview.bounds
        }
    }

    private func updatePriority(_ priority: UILayoutPriority, constraints: [NSLayoutConstraint]) {
        constraints.forEach { $0.priority = priority }
    }

    private func updateContentSpacingConstraints() {
        var isPrevItemVisible = false

        self.contentSpacingConstraints.forEach {
            let firstItemView = $0.firstItem as? UIView
            let secondItemView = $0.secondItem as? UIView

            let isFirstItemVisible = firstItemView?.isHidden != true && firstItemView?.intrinsicContentSize != CGSize.zero
            let isSecondItemVisible = secondItemView?.isHidden != true && secondItemView?.intrinsicContentSize != CGSize.zero

            $0.constant = isFirstItemVisible && (isSecondItemVisible || isPrevItemVisible) ? SBProgressHUD.contentSpacing : 0.0

            isPrevItemVisible = isPrevItemVisible || isSecondItemVisible
        }
    }

    private func updateProgressHUD() {
        self.resetIndicatorView()

        self.updateColor()

        self.updateProgress()
    }

    private func resetIndicatorView() {
        var indicatorView = self.indicatorView

        switch self.style {
            case .activityIndicator where !(indicatorView is UIActivityIndicatorView):
                indicatorView?.removeFromSuperview()

                let activityIndicator: UIActivityIndicatorView
                if #available(iOS 13.0, *) {
                    activityIndicator = UIActivityIndicatorView(style: .large)
                } else {
                    activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
                }

                activityIndicator.startAnimating()

                indicatorView = activityIndicator
            case .linearProgress:
                indicatorView?.removeFromSuperview()

                indicatorView = SBProgressContainerView(style: .linear)
            case .doughnutProgress:
                indicatorView?.removeFromSuperview()

                indicatorView = SBProgressContainerView(style: .doughnut)
            case .pieProgress:
                indicatorView?.removeFromSuperview()

                indicatorView = SBProgressContainerView(style: .pie)
            case .textLabel:
                indicatorView?.removeFromSuperview()

                indicatorView = nil
            case .customView where indicatorView != self.customView:
                indicatorView?.removeFromSuperview()

                indicatorView = self.customView
            default:
                break
        }

        indicatorView?.translatesAutoresizingMaskIntoConstraints = false

        indicatorView?.setContentCompressionResistancePriority(.init(rawValue: 998.0), for: .horizontal)
        indicatorView?.setContentCompressionResistancePriority(.init(rawValue: 998.0), for: .vertical)

        if indicatorView != nil {
            self.bezelView.addSubview(indicatorView!)
        }

        self.indicatorView = indicatorView

        self.setNeedsUpdateConstraints()
    }

    private func updateColor() {
        switch self.indicatorView {
            case is UIActivityIndicatorView:
                let appearance = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [SBProgressHUD.self])

                if appearance.color == nil {
                    (self.indicatorView as! UIActivityIndicatorView).color = self.color
                }
            case is SBProgressContainerView:
                let appearance = SBProgressContainerView.appearance(whenContainedInInstancesOf: [SBProgressHUD.self])

                if appearance.trackTintColor == nil {
                    (self.indicatorView as! SBProgressContainerView).trackTintColor = UIColor.clear
                }
                if appearance.progressTintColor == nil {
                    (self.indicatorView as! SBProgressContainerView).progressTintColor = self.color
                }
            default:
                self.indicatorView?.tintColor = self.color
        }

        self.titleLabel.textColor = self.titleTextColor ?? self.color

        self.detailsLabel.textColor = self.detailsTextColor ?? self.color
    }

    private func updateProgress() {
        if self.indicatorView is SBProgressContainerView {
            (self.indicatorView as! SBProgressContainerView).progress = self.progress
        }
    }

    private func resetObservingProgressValueChangedTimer(_ isEnabled: Bool) {
        if isEnabled && self.observingProgressValueChangedTimer == nil && self.progressObject != nil {
            self.observingProgressValueChangedTimer = CADisplayLink(target: self, selector: #selector(self.observingProgressValueChange))
        } else if self.observingProgressValueChangedTimer != nil {
            self.observingProgressValueChangedTimer?.invalidate()

            self.observingProgressValueChangedTimer = nil
        }
    }

    private func resetMotionEffects() {
        if self.enabledMotionEffects && self.motionEffectGroup == nil {
            let tiltOffset: CGFloat = 10.0

            let motionEffectOfHorizontalAxisTilt = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            motionEffectOfHorizontalAxisTilt.minimumRelativeValue = -tiltOffset
            motionEffectOfHorizontalAxisTilt.maximumRelativeValue = tiltOffset

            let motionEffectOfVerticalAxisTilt = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            motionEffectOfVerticalAxisTilt.minimumRelativeValue = -tiltOffset
            motionEffectOfVerticalAxisTilt.maximumRelativeValue = tiltOffset

            let motionEffectGroup = UIMotionEffectGroup()
            motionEffectGroup.motionEffects = [motionEffectOfHorizontalAxisTilt, motionEffectOfVerticalAxisTilt]

            self.bezelView.addMotionEffect(motionEffectGroup)

            self.motionEffectGroup = motionEffectGroup
        } else if self.motionEffectGroup != nil {
            self.bezelView.removeMotionEffect(self.motionEffectGroup!)

            self.motionEffectGroup = nil
        }
    }

    @objc
    private func didChangeStatusBarOrientation(_ notification: Notification) {
        self.updateOrientation()
    }

    @objc
    private func handleGracePeriodTimer(_ timer: Timer) {
        if self.isActivity {
            self.showUsingAnimation(self.isUsingAnimation)
        }
    }

    @objc
    private func handleMinimumDisplayingTimer(_ timer: Timer) {
        self.hideUsingAnimation(self.isUsingAnimation)
    }

    @objc
    private func handleDelayHideTimer(_ timer: Timer) {
        self.hideProgressHUD(animated: timer.userInfo as! Bool)
    }

    @objc
    private func observingProgressValueChange() {
        self.progress = Float(self.progressObject!.fractionCompleted)
    }
}

#endif
