//
//  SnackBarController.swift
//  MMOA
//
//  Created by jedmin on 2021/03/08.
//

import SnapKit
import Spring
import UIKit

internal protocol SnackBarable {
    func addAction(_ action: SnackBarAction)
    func show(_ duration: Double)
}

internal class SnackBarController: NSObject {
    internal let title: String
    private var actions = [SnackBarAction]()
    private var containerView: UIView?
    private var keyWindow: UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    private let hiddenPosition = -200

    internal init(title: String) {
        self.title = title
    }

    internal func addAction(_ action: SnackBarAction) {
        guard actions.count < 2 else {
            return
        }

        actions.append(action)
    }

    internal static func show(message: String, actions: [SnackBarAction]? = nil) {
        guard !SnackBarManager.shared.exist(message: message) else { return }

        let snackBar = SnackBarController(title: message)
        actions?.forEach {
            snackBar.addAction($0)
        }

        snackBar.show(20.0)
    }

    private func show(_ duration: Double) {
        setupUI()
        setupGesture()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.remove()
        }

        SnackBarManager.shared.addSnackBar(self)
        setupAnimation()
    }

    private func setupUI() {
        let containerView = UIView()
        containerView.backgroundColor = .black
        UIApplication.shared.delegate?.window??.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(hiddenPosition)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let padding: CGFloat = 21

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0

        containerView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(57)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.greaterThanOrEqualTo(22)

            if actions.isEmpty {
                make.bottom.equalToSuperview().offset(-padding)
            }
        }

        let buttonHeight = 30

        if actions.count == 2 {
            let rightButton = actions[1].makeUI()
            containerView.addSubview(rightButton)

            rightButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-26)
                make.width.greaterThanOrEqualTo(20)
                make.height.equalTo(buttonHeight)
                make.top.equalTo(titleLabel.snp_bottomMargin).offset(20)
                make.bottom.equalToSuperview().offset(-18)
            }

            let leftButton = actions[0].makeUI()
            containerView.addSubview(leftButton)

            leftButton.snp.makeConstraints { make in
                make.trailing.equalTo(rightButton.snp.leading).offset(-11)
                make.width.greaterThanOrEqualTo(20)
                make.height.equalTo(buttonHeight)
                make.top.equalTo(titleLabel.snp_bottomMargin).offset(20)
                make.bottom.equalToSuperview().offset(-18)
            }

            rightButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
            leftButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        }

        UIApplication.shared.delegate?.window??.layoutIfNeeded()
        self.containerView = containerView
    }

    private func setupGesture() {
        // 버튼이 없는 경우는 탭으로 remove 제스처 추가
        if actions.isEmpty {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(remove))
            containerView?.addGestureRecognizer(tapGesture)
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(remove))
        swipeGesture.direction = .up
        containerView?.addGestureRecognizer(swipeGesture)
    }

    private func setupAnimation() {
        guard let view = containerView else { return }
        view.snp.updateConstraints { make in
            make.top.equalToSuperview()
        }

        UIView.animate(withDuration: 0.2) {
            self.keyWindow?.layoutIfNeeded()
        }
    }

    @objc
    private func remove() {
        guard let view = containerView else { return }
        view.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(hiddenPosition)
        }

        UIView.animate(withDuration: 0.2) {
            self.keyWindow?.layoutIfNeeded()
        } completion: { _ in
            SnackBarManager.shared.removeSnackBar(self)
            self.containerView?.removeFromSuperview()
            self.containerView = nil

            if !self.actions.isEmpty {
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
    }
}
