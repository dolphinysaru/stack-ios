//
//  Device.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import Foundation
import UIKit

internal struct Device { }

extension Device {
    internal static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    internal static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    internal static var isSmallWidthDevice: Bool { // iPhone SE 1st generation
        screenWidth <= 320
    }

    internal static var isSmallHeightDevice: Bool { // iPhone SE 1st generation
        screenHeight <= 568
    }

    internal static var isMediumHeightDevice: Bool { // iPhone 8 이하
        screenHeight <= 667
    }

    // MARK: -
    internal static var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
    }

    internal static var safeAreaInsetsTop: CGFloat {
        safeAreaInsets.top
    }

    internal static var safeAreaInsetsBottom: CGFloat {
        safeAreaInsets.bottom
    }

    internal static var safeAreaInsetsLeft: CGFloat {
        safeAreaInsets.left
    }

    internal static var safeAreaInsetsRight: CGFloat {
        safeAreaInsets.right
    }

    // MARK: -
    public static var singlePixel: CGFloat { 1.0 / UIScreen.main.scale }
}
