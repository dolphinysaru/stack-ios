//
//  LoadableNib.swift
//  MazyngaAttic
//
//  Created by jed.min on 2016. 9. 2..
//  Copyright © 2016년 Kakao. All rights reserved.
//

import Foundation
import UIKit

public protocol LoadableNib: AnyObject {
    static var loadNib: UINib { get }

    static func loadViewWithNib(owner: Any?) -> Self
}

public extension LoadableNib where Self: UIView {
    static var nibName: String {
        String(describing: self)
    }

    static var loadNib: UINib {
        UINib(nibName: nibName, bundle: Bundle.main)
    }

    static func loadViewWithNib(owner: Any? = self) -> Self {
        let viewList: [Any] = loadNib.instantiate(withOwner: owner, options: nil)
        guard !viewList.isEmpty, let view = viewList.first as? Self else { fatalError("Failed load nib file name: \(nibName)") }

        return view
    }
}

extension UIView: LoadableNib {}

public extension LoadableNib where Self: UIViewController {
    static var nibName: String {
        String(describing: self)
    }

    static var loadNib: UINib {
        UINib(nibName: nibName, bundle: Bundle.main)
    }

    static func loadViewWithNib(owner: Any? = nil) -> Self {
        self.init(nibName: nibName, bundle: Bundle.main)
    }

    static func loadViewWithNib(name: String) -> Self {
        self.init(nibName: name, bundle: Bundle.main)
    }
}
extension UIViewController: LoadableNib {}
