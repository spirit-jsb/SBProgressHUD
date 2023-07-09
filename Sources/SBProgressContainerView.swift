//
//  SBProgressContainerView.swift
//  SBProgressHUD
//
//  Created by Max on 2023/7/8.
//

#if canImport(UIKit)

import UIKit

internal final class SBProgressContainerView: UIView {
    enum Style {
        case linear
        case doughnut
        case pie
    }

    let style: Style

    var progress: Float {
        willSet {
            if newValue != self.progress {
                self.setNeedsDisplay()
            }
        }
    }

    @objc
    dynamic var trackTintColor: UIColor? {
        willSet {
            if newValue != self.trackTintColor {
                self.setNeedsDisplay()
            }
        }
    }

    @objc
    dynamic var progressTintColor: UIColor? {
        willSet {
            if newValue != self.progressTintColor {
                self.setNeedsDisplay()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let intrinsicContentWidth = self.contentMargin.left + self.contentSize.width + self.contentMargin.right
        let intrinsicContentHeight = self.contentMargin.top + self.contentSize.height + self.contentMargin.bottom

        return CGSize(width: intrinsicContentWidth, height: intrinsicContentHeight)
    }

    private let contentSize: CGSize
    private let contentLineWidth: CGFloat
    private let contentMargin: UIEdgeInsets

    private let backgroundContentLayer = CAShapeLayer()
    private let progressContentLayer = CAShapeLayer()

    init(style: Style) {
        self.style = style

        self.progress = 0.0

        self.trackTintColor = .clear

        if #available(iOS 13.0, *) {
            self.progressTintColor = UIColor(dynamicProvider: { $0.userInterfaceStyle == .light ? UIColor(white: 0.15, alpha: 1.0) : UIColor(white: 0.95, alpha: 1.0) })
        } else {
            self.progressTintColor = UIColor(white: 0.15, alpha: 1.0)
        }

        switch style {
            case .linear:
                self.contentSize = .init(width: 140.0, height: 12.0)
            case .doughnut:
                self.contentSize = .init(width: 60.0, height: 60.0)
            case .pie:
                self.contentSize = .init(width: 60.0, height: 60.0)
        }
        self.contentLineWidth = 1.0
        self.contentMargin = .init(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

        super.init(frame: .zero)

        self.backgroundColor = .clear
        self.isOpaque = false

        self.layer.addSublayer(self.backgroundContentLayer)
        self.layer.addSublayer(self.progressContentLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {}

    private func updateContentLayer(_ rect: CGRect) {
        self.backgroundContentLayer.frame = rect
        self.backgroundContentLayer.fillColor = self.trackTintColor?.cgColor
        self.backgroundContentLayer.strokeColor = self.progressTintColor?.cgColor

        self.progressContentLayer.frame = rect
        self.progressContentLayer.fillColor = self.progressTintColor?.cgColor
        self.progressContentLayer.strokeColor = nil
    }

    private func backgroundContentPathBuilder(_ rect: CGRect) -> CGPath? {
        let backgroundContentPath: CGPath?
        switch self.style {
            case .linear:
                backgroundContentPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.height / 2.0).cgPath
            case .doughnut, .pie:
                backgroundContentPath = UIBezierPath(ovalIn: rect).cgPath
        }
        return backgroundContentPath
    }

    private func progressContentPathBuilder(_ rect: CGRect) -> CGPath? {
        fatalError("progressContentPathBuilder(_:) has not been implemented")
    }

    private func linearProgressContentPathBuilder(_ rect: CGRect, progress: Float) -> CGPath? {
        fatalError("linearProgressContentPathBuilder(_:progress:) has not been implemented")
    }

    private func doughnutProgressContentPathBuilder(_ rect: CGRect, progress: Float) -> CGPath? {
        fatalError("doughnutProgressContentPathBuilder(_:progress:) has not been implemented")
    }

    private func pieProgressContentPathBuilder(_ rect: CGRect, progress: Float) -> CGPath? {
        fatalError("pieProgressContentPathBuilder(_:progress:) has not been implemented")
    }
}

#endif
