//
//  UIImage+.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import Foundation
import UIKit

extension UIImage {
    internal class func imageWithEmoji(emoji: String, fontSize: CGFloat, size: CGSize, sizeToFit: Bool = true) -> UIImage {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        label.text = String(emoji.prefix(1))
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        if sizeToFit {
            label.sizeToFit()
        }

        let renderer = UIGraphicsImageRenderer(size: label.bounds.size)
        let image = renderer.image { _ in
            label.layer.render(in: UIGraphicsGetCurrentContext()!)
        }

        return image
    }
}
