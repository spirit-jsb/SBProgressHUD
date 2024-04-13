# SBProgressHUD

<p align="center">
    <a href="https://cocoapods.org/pods/SBProgressHUD"><img src="https://img.shields.io/badge/Cocoapods-supported-brightgreen"></a> 
    <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-supported-brightgreen"></a> 
    <a href="https://github.com/spirit-jsb/SBProgressHUD"><img src="https://img.shields.io/github/v/release/spirit-jsb/SBProgressHUD?display_name=tag"/></a>
    <a href="https://github.com/spirit-jsb/SBProgressHUD"><img src="https://img.shields.io/cocoapods/p/ios"/></a>
    <a href="https://github.com/spirit-jsb/SBProgressHUD/blob/master/LICENSE"><img src="https://img.shields.io/github/license/spirit-jsb/SBProgressHUD"/></a>
</p>

## 视图结构
```
SBBackgroundContainerView (Background View)
        │
        SBBackgroundContainerView (Bezel View)
                  │ ┌───────────────┐
                  ├─┤Top Spacer View│    ┌─Activity Indicator
                  │ └───────────────┘    │
                  │                      ├─Linear Progress
                  ├──Indicator───────────┤
                  │                      ├─Doughnut Progress
                  ├──Title Label         │
                  │                      ├─Pie Progress
                  ├──Details Label       │
                  │                      ├─Text Label
                  │ ┌──────────────────┐ │
                  └─┤Bottom Spacer View│ └─Custom View
                    └──────────────────┘
```

## API
### Property
* delegate
* completion
* style
* animationType
* progress
* progressObject
* color
* backgroundViewColor
* bezelViewColor
* bezelViewBlurEffectStyle
* titleText
* titleFont
* titleTextColor
* titleAttributedText
* detailsText
* detailsFont
* detailsTextColor
* detailsAttributedText
* offset
* margin
* minimumSize
* contentMargin
* gracePeriod
* minimumDisplayingTime*
* removeFromSuperviewWhenStopped
* enabledMotionEffects
* customView

### Method
* init()
* showProgressHUD(onView:animated:)
* hideProgressHUD(fromView:animated:)
* getProgressHUD(fromView:)
* showProgressHUD(animated:)
* hideProgressHUD(animated:)
* delayHideProgressHUD(_:animated:)

## 限制条件
- iOS 11.0+
- Swift 5.0+    

## 安装
### **Cocoapods**
```
pod 'SBProgressHUD-Spirit', '~> 1.0'
```
### **Swift Package Manager**
```
https://github.com/spirit-jsb/SBProgressHUD.git
```

## 作者
spirit-jsb, sibo_jian_29903549@163.com

## 许可文件
`SBProgressHUD` 可在 `MIT` 许可下使用，更多详情请参阅许可文件