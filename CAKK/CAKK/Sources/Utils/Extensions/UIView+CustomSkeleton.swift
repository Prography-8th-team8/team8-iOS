//
//  UIView+CustomSkeleton.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/13.
//

import SkeletonView

extension UIView {
  func showCustomSkeleton() {
    showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .systemGray6, secondaryColor: .systemGray5), transition: .crossDissolve(0.15))
  }
}
