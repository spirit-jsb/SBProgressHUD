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
        let actualRect = rect.inset(by: UIEdgeInsets(top: 1.5, left: 1.5, bottom: 1.5, right: 1.5))

        let amount = actualRect.size.width * CGFloat(progress)
        
        let radius = actualRect.size.height / 2.0

        let leftCenter = CGPoint(x: actualRect.minX + radius, y: actualRect.midY)
        let rightCenter = CGPoint(x: actualRect.minX + actualRect.size.width - radius, y: actualRect.midY)

        let linearProgressContentPath = UIBezierPath()

        if amount > 0 && amount < radius {
            var angle = acos((radius - amount) / radius)
            if angle.isNaN {
                angle = 0.0
            }

            linearProgressContentPath.move(to: .init(x: actualRect.minX, y: actualRect.midY))
            linearProgressContentPath.addArc(withCenter: leftCenter, radius: radius, startAngle: .pi, endAngle: .pi + angle, clockwise: true)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.midY))

            linearProgressContentPath.move(to: .init(x: actualRect.minX, y: actualRect.midY))
            linearProgressContentPath.addArc(withCenter: leftCenter, radius: radius, startAngle: .pi, endAngle: .pi - angle, clockwise: false)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.midY))
        } else if amount >= radius && amount <= (actualRect.size.width - radius) {
            linearProgressContentPath.move(to: .init(x: actualRect.minX, y: actualRect.midY))
            linearProgressContentPath.addArc(withCenter: leftCenter, radius: radius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: true)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.minY))
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.midY))
            
            linearProgressContentPath.move(to: .init(x: actualRect.minX, y: actualRect.midY))
            linearProgressContentPath.addArc(withCenter: leftCenter, radius: radius, startAngle: .pi, endAngle: 0.5 * .pi, clockwise: false)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.maxY))
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.midY))
        } else if amount > (actualRect.size.width - radius) && amount < actualRect.size.width {
            var angle = acos((amount - (actualRect.size.width - radius)) / radius)
            if angle.isNaN {
              angle = 0.0
            }
            
            linearProgressContentPath.move(to: .init(x: actualRect.minX, y: actualRect.midY))
            linearProgressContentPath.addArc(withCenter: leftCenter, radius: radius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: true)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + (actualRect.size.width - radius), y: actualRect.minY))
            linearProgressContentPath.addArc(withCenter: rightCenter, radius: radius, startAngle: 1.5 * .pi, endAngle: (2.0 * .pi) - angle, clockwise: true)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.midY))
            
            linearProgressContentPath.move(to: .init(x: actualRect.minX, y: actualRect.midY))
            linearProgressContentPath.addArc(withCenter: leftCenter, radius: radius, startAngle: .pi, endAngle: 0.5 * .pi, clockwise: false)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + (actualRect.size.width - radius), y: actualRect.maxY))
            linearProgressContentPath.addArc(withCenter: rightCenter, radius: radius, startAngle: 0.5 * .pi, endAngle: angle, clockwise: false)
            linearProgressContentPath.addLine(to: .init(x: actualRect.minX + amount, y: actualRect.midY))
        }

        return linearProgressContentPath.cgPath
    }

    private func doughnutProgressContentPathBuilder(_ rect: CGRect, progress: Float) -> CGPath? {
        let lineWidth: CGFloat = 3.0

        let arcCenter = CGPoint(x: rect.midX, y: rect.midY)
        let startAngle: CGFloat = -0.5 * .pi
        let endAngle: CGFloat = 2.0 * .pi * CGFloat(progress) + (-0.5 * .pi)

        let doughnutInsideRadius = rect.size.width / 2.0 - lineWidth
        let doughnutOutsideRadius = rect.size.width / 2.0

        let doughnutInsideContentPath = UIBezierPath(arcCenter: arcCenter, radius: doughnutInsideRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        doughnutInsideContentPath.addLine(to: arcCenter)

        let doughnutOutsideContentPath = UIBezierPath(arcCenter: arcCenter, radius: doughnutOutsideRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        doughnutOutsideContentPath.addLine(to: arcCenter)

        let doughnutProgressContentPath = UIBezierPath()
        doughnutProgressContentPath.append(doughnutInsideContentPath.reversing())
        doughnutProgressContentPath.append(doughnutOutsideContentPath)

        return doughnutProgressContentPath.cgPath
    }

    private func pieProgressContentPathBuilder(_ rect: CGRect, progress: Float) -> CGPath? {
        let arcCenter = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.size.width / 2.0
        let startAngle: CGFloat = -0.5 * .pi
        let endAngle: CGFloat = 2.0 * .pi * CGFloat(progress) + (-0.5 * .pi)

        let pieProgressContentPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        pieProgressContentPath.addLine(to: arcCenter)

        return pieProgressContentPath.cgPath
    }
}

#endif
