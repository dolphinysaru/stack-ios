//
//  SnackBarAction.swift
//  MMOA
//
//  Created by jedmin on 2021/03/08.
//

import UIKit

extension SnackBarAction {
    internal enum Style: Int {
        case `default` = 0
        case cancel = 1
    }
}

internal class SnackBarAction: NSObject {
    internal let title: String
    internal let style: SnackBarAction.Style
    private let handler: ((SnackBarAction) -> Void)?
    private var button: UIButton?

    internal init(title: String, style: SnackBarAction.Style, handler: ((SnackBarAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension SnackBarAction {
    internal func makeUI() -> UIButton {
        let button = UIButton(type: .custom)

        button.setTitle(title, for: .normal)

        let font = UIFont.systemFont(ofSize: 13, weight: .medium)
        var fontColor: UIColor
        var backgroundColor: UIColor

        switch style {
        case .default:
            fontColor = .black
            backgroundColor = .white

        case .cancel:
            fontColor = .white
            backgroundColor = UIColor(hex: "272727")
        }

        button.titleLabel?.font = font
        button.backgroundColor = backgroundColor
        button.setTitleColor(fontColor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15

        button.addTarget(self, action: #selector(buttonTouchInsideAction(_:)), for: .touchUpInside)

        return button
    }

    @objc
    private func buttonTouchInsideAction(_ sender: UIButton) {
        handler?(self)
    }
}
