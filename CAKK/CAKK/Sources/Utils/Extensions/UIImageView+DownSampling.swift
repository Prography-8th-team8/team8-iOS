//
//  UIImageView+DownSampling.swift
//  CAKK
//
//  Created by Mason Kim on 2023/08/10.
//

import Foundation
import Kingfisher

extension UIImageView {
  private static let smallDownSamplingProcessor = DownsamplingImageProcessor(size: .init(width: 100, height: 100))
  private static let middleDownSamplingProcessor = DownsamplingImageProcessor(size: .init(width: 200, height: 200))
  
  enum DownSamplingSize {
    case small
    case middle
    
    var processor: DownsamplingImageProcessor {
      switch self {
      case .small:
        return UIImageView.smallDownSamplingProcessor
      case .middle:
        return UIImageView.middleDownSamplingProcessor
      }
    }
  }
  
  func setDownsampledImage(url: URL?, size: DownSamplingSize = .small, placeholder: Placeholder? = nil) {
    self.kf.setImage(
      with: url,
      placeholder: placeholder,
      options: [
        .processor(size.processor),
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage
      ]
    )
  }
}
