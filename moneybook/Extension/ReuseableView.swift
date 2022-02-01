//
//  ReusableView.swift
//  kakaoNow
//
//  Created by jed.min on 2017. 4. 28..
//  Copyright © 2017년 Kakao. All rights reserved.
//

import Foundation
import UIKit

internal protocol ReusableView: AnyObject { }

extension ReusableView where Self: UIView {
    internal static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }
extension UITableViewHeaderFooterView: ReusableView { }
extension UICollectionView: ReusableView { }
extension UICollectionReusableView: ReusableView { }
