//
//  ViewDataState.swift
//  ViewDataState
//
//  Created by 王叶庆 on 2021/3/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public typealias ViewDataStateCallback = () -> Void
public typealias ViewDataStateGetter = (ViewDataState, UIView) -> StateView?
public typealias DataStateHandler = () -> Void

public protocol DataStateHandleable where Self: UIView {
    var dataStateHandler: DataStateHandler? { get set }
}


public enum ViewDataState {
    
    public struct Info: ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByNilLiteral, ExpressibleByStringInterpolation, Hashable {

        public typealias ArrayLiteralElement = String
        public typealias StringLiteralType = String
        
        public let title: String?
        public let subTitle: String?
        
        public init(title: String?, subTitle: String?) {
            self.title = title
            self.subTitle = subTitle
        }
        public init(stringLiteral value: StringLiteralType) {
            self.title = value
            self.subTitle = nil
        }
        public init(unicodeScalarLiteral value: String) {
            self.title = value
            self.subTitle = nil
        }
        public init(extendedGraphemeClusterLiteral value: String) {
            self.title = value
            self.subTitle = nil
        }
        public init(arrayLiteral elements: String...) {
            self.title = elements.first
            if elements.count > 1 {
                self.subTitle = elements[1]
            } else {
                self.subTitle = nil
            }
        }
        public init(nilLiteral: ()) {
            self.title = nil
            self.subTitle = nil
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(subTitle)
        }
    }
    
    case none
    case loading(Info /* 提示信息 */, ViewDataStateCallback? /* 点击时的回调 */ )
    case empty(Info /* 提示信息 */, ViewDataStateCallback? /* 点击时的回调 */ )
    case error(Info /* 提示信息 */, ViewDataStateCallback? /* 点击时回调 */ )
    
    public static let loading = ViewDataState.loading(nil, nil)
    public static let empty = ViewDataState.empty(nil, nil)
    public static let error = ViewDataState.error(nil, nil)
}

public struct StateView {
    public struct Info {
        let offset: UIOffset?
        public init(offset: UIOffset?) {
            self.offset = offset
        }
    }

    let view: UIView
    let info: Info?

    public init(_ view: UIView, info: Info? = nil) {
        self.view = view
        self.info = info
    }
}

public class ViewDataStateManager {
    public static let shared = ViewDataStateManager()
    private init() {}
    fileprivate var viewGetter: ViewDataStateGetter?
    public func register(_ getter: @escaping ViewDataStateGetter) {
        viewGetter = getter
    }
}

extension ViewDataState: Identifiable {
    public var id: String {
        switch self {
        case .none:
            return "none"
        case let .loading(message, callback):
            return "loading-\(message.hashValue)-\(callback == nil ? 0 : 1)"
        case let .empty(message, callback):
            return "empty-\(message.hashValue)-\(callback == nil ? 0 : 1)"
        case let .error(message, callback):
            return "error-\(message.hashValue)-\(callback == nil ? 0 : 1)"
        }
    }
}

extension ViewDataState: Equatable {
    public static func == (lhs: ViewDataState, rhs: ViewDataState) -> Bool {
        lhs.id == rhs.id
    }
}

public struct ViewDataStateWrapper<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol ViewDataStateCompatible {
    associatedtype BaseType
    var viewData: ViewDataStateWrapper<BaseType> { get set }
}

public extension ViewDataStateCompatible {
    var viewData: ViewDataStateWrapper<Self> {
        get {
            ViewDataStateWrapper(self)
        }
        // swiftlint:disable all
        set {}
        // swiftlint:enable all
    }
}

extension UIView: ViewDataStateCompatible {}
private enum AssociatedKeys {
    static var state = "view.data.state.state"
    static var view = "view.data.state.view"
}

public extension ViewDataStateWrapper where Base: UIView {
    var state: ViewDataState {
        get {
            #if DEBUG
                print("警告！！！无论什么情况，我只返给你none")
            #endif
            return .none
        }
        set {
            let id = objc_getAssociatedObject(base, &AssociatedKeys.state) as? String ?? ViewDataState.none.id
            guard newValue.id != id else {
                return
            }
            objc_setAssociatedObject(base, &AssociatedKeys.state, newValue.id, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let view = objc_getAssociatedObject(base, &AssociatedKeys.view) as? UIView {
                view.removeFromSuperview()
            }
            guard newValue != .none else {
                return
            }
            guard let getter = ViewDataStateManager.shared.viewGetter else {
                fatalError("请先注册ViewDataStateGetter")
            }
            guard let stateView = getter(newValue, base) else {
                return
            }
            base.addSubview(stateView.view)
            objc_setAssociatedObject(base, &AssociatedKeys.view, stateView.view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            stateView.view.translatesAutoresizingMaskIntoConstraints = false
            let offsetH = stateView.info?.offset?.horizontal ?? 0
            let offsetV = stateView.info?.offset?.vertical ?? 0
            let centerH = stateView.view.centerXAnchor.constraint(equalTo: base.centerXAnchor)
            centerH.constant = offsetH
            let centerV = stateView.view.centerYAnchor.constraint(equalTo: base.centerYAnchor)
            centerV.constant = offsetV
            base.addConstraints([centerH, centerV])
            switch newValue {
            case let .loading(_, callback), let .empty(_, callback), let .error(_, callback):
                guard let view = stateView.view as? DataStateHandleable else {
                    return
                }
                view.dataStateHandler = callback
            default:
                return
            }
        }
    }
}
