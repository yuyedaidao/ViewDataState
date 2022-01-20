//
//  ViewController.swift
//  ViewDataState
//
//  Created by wyqpadding@gmail.com on 03/08/2021.
//  Copyright (c) 2021 wyqpadding@gmail.com. All rights reserved.
//

import UIKit
import ViewDataState

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ViewDataStateManager.shared.register { state, _ -> StateView? in
            switch state {
            case .loading:
                let label = UILabel()
                label.text = "加载中"
                return StateView(label)
            case .empty:
                return StateView(EmptyView())
            case .error:
                let label = UILabel()
                label.text = "骂骂咧咧"
                return StateView(label)
            case .none:
                return nil
            }
        }
        view.viewData.state = ViewDataState.loading
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(4)) {
            self.view.viewData.state = .empty(nil, self.reloadData)
        }
    }

    func reloadData() {
        print("hello")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class EmptyView: UIView, DataStateHandleable {
    var dataStateHandler: DataStateHandler?

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.red
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        addGestureRecognizer(tap)
    }

    @objc func tapHandler() {
        dataStateHandler?()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
}
