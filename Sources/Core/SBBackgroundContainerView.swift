//
//  SBBackgroundContainerView.swift
//
//  Created by Max on 2023/7/13
//
//  Copyright © 2023 Max. All rights reserved.
//

#if canImport(UIKit)

import UIKit

internal final class SBBackgroundContainerView: UIView {
    enum Style {
        case blur
        case solidColor
    }

    let style: Style

    var color: UIColor? {
        didSet {
            if oldValue != self.color {
                self.updateBackgroundColor()
            }
        }
    }

    var blurEffectStyle: UIBlurEffect.Style {
        didSet {
            if oldValue != self.blurEffectStyle {
                self.resetVisualEffects()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }

    private var visualEffectView: UIVisualEffectView?

    init(style: Style) {
        self.style = style

        if #available(iOS 13.0, *) {
            self.blurEffectStyle = .systemThickMaterial
        } else {
            self.color = UIColor(white: 0.8, alpha: 0.6)
            self.blurEffectStyle = .light
        }

        super.init(frame: .zero)

        self.clipsToBounds = true

        self.resetVisualEffects()
        self.updateBackgroundColor()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func resetVisualEffects() {
        self.visualEffectView?.removeFromSuperview()
        self.visualEffectView = nil

        switch self.style {
            case .blur:
                self.layer.allowsGroupOpacity = false

                let blurEffect = UIBlurEffect(style: self.blurEffectStyle)
                let visualEffectView = UIVisualEffectView(effect: blurEffect)
                visualEffectView.frame = self.bounds
                visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                self.insertSubview(visualEffectView, at: 0)

                self.visualEffectView = visualEffectView
            case .solidColor:
                self.layer.allowsGroupOpacity = true
        }
    }

    private func updateBackgroundColor() {
        self.backgroundColor = self.color
    }
}

#endif
