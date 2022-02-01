//
//  UITableView+Register.swift
//  MMOA
//
//  Created by soo.hyun on 2021/03/09.
//

import UIKit

extension UITableView {
    // MARK: - Cell
    internal func registerNib<T: UITableViewCell>(_: T.Type) {
        register(T.loadNib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    internal func registerClass<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    internal func dequeueReusableCell<T: UITableViewCell>(_: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    internal func dequeueReusableCell<T: UITableViewCell>(_: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    // MARK: - Supplementary View
    internal func registerNib<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.loadNib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    internal func registerClass<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    internal func dequeueReusableView<T: UITableViewHeaderFooterView>(_ : T.Type) -> T {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}
