//
//  UIView+Animation.swift
//  CAKK
//
//  Created by Mason Kim on 2023/04/05.
//

import UIKit

extension UIView {
    func fadeIn(withDuration duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 1 },
                       completion: { _ in
            completion?()
        })
    }

    func fadeOut(withDuration duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 0 },
                       completion: { _ in
            self.isHidden = true
            completion?()
        })
    }

}
