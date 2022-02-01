//
//  UICollectionView+Register.swift
//  MMOA
//
//  Created by jed.min on 2017. 4. 28..
//  Copyright © 2017년 Kakao. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    // MARK: - Cell
    internal func registerNib<T: UICollectionViewCell>(_: T.Type) {
        register(T.loadNib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    internal func registerClass<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    internal func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath, cellType: T.Type) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(cellType.reuseIdentifier)")
        }
        return cell
    }

    // MARK: - Supplementary View
    internal func registerHeaderNib<T: UICollectionReusableView>(_: T.Type) {
        register(T.loadNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
    }

    internal func registerFooterNib<T: UICollectionReusableView>(_: T.Type) {
        register(T.loadNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
    }

    internal func registerHeaderClass<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
    }

    internal func registerFooterClass<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
    }

    internal func dequeueReusableHeaderView<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath, cellType: T.Type) -> T {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(cellType.reuseIdentifier)") }
        return supplementaryView
    }

    internal func dequeueReusableFooterView<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath, cellType: T.Type) -> T {
        guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(cellType.reuseIdentifier)") }
        return supplementaryView
    }
}
