//
//  SnackBarManager.swift
//  MMOA
//
//  Created by jedmin on 2021/03/08.
//

import Foundation

internal class SnackBarManager {
    internal static let shared = SnackBarManager()
    private var snackBars = [SnackBarController]()

    internal var currentSnackBar: SnackBarController? {
        snackBars.first
    }

    internal func addSnackBar(_ snackBar: SnackBarController) {
        snackBars.append(snackBar)
    }

    internal func removeSnackBar(_ snackBar: SnackBarController) {
        if let index = snackBars.firstIndex(where: { $0 == snackBar }) {
            snackBars.remove(at: index)
        }
    }

    internal func exist(message: String) -> Bool {
        let exist = snackBars.filter {
            $0.title == message
        }

        return !exist.isEmpty
    }
}
