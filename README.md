# ViewDataState

[![CI Status](https://img.shields.io/travis/wyqpadding@gmail.com/ViewDataState.svg?style=flat)](https://travis-ci.org/wyqpadding@gmail.com/ViewDataState)
[![Version](https://img.shields.io/cocoapods/v/ViewDataState.svg?style=flat)](https://cocoapods.org/pods/ViewDataState)
[![License](https://img.shields.io/cocoapods/l/ViewDataState.svg?style=flat)](https://cocoapods.org/pods/ViewDataState)
[![Platform](https://img.shields.io/cocoapods/p/ViewDataState.svg?style=flat)](https://cocoapods.org/pods/ViewDataState)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ViewDataState is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ViewDataState'
# or
pod 'ViewDataState', :git => 'https://github.com/yuyedaidao/ViewDataState.git'
```

## Use
#### 统一注册视图
```Swift
ViewDataStateManager.shared.register { (state, _) -> StateView? in
    switch state {
    case .loading:
        let label = UILabel()
        label.text = "加载中"
        return StateView(label)
    case .empty(_, _):
        return StateView(EmptyView())
    case .error(_, _):
        let label = UILabel()
        label.text = "骂骂咧咧"
        return StateView(label)
    case .none:
        return nil
    }
}
```
#### 调用
```Swift
// loading
view.viewData.state = ViewDataState.loading
// empty
view.viewData.state = .emtpy(nil, nil)
view.viewData.state = .empty("暂无数据", callback)
view.viewData.state = .emtpy(["暂无数据", "点击重新加载"]) {
    loadData()
}
// error 
view.viewData.state = .error(["加载失败", "点击重新加载"]) {
    loadData()
}
```
## Author

wyqpadding@gmail.com, wyqpadding@gmail.com

## License

ViewDataState is available under the MIT license. See the LICENSE file for more info.
