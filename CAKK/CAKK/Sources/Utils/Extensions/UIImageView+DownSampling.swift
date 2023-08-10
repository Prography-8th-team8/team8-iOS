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
  
  /// 다운샘플링 한 이미지를 이미지뷰에 지정하고, 캐시에 저장합니다.
  ///
  /// 캐시 키가 다르기 때문에 다운샘플링 되지 않은 원본 이미지를 지정하려면 기존 `kf.setImage` 를 사용하면 따로 처리됩니다.
  func setDownsampledImage(with url: URL?,
                           size: DownSamplingSize = .small,
                           placeholder: Placeholder? = nil,
                           completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
    guard let url else { return }
    let cacheKey = "\(url.absoluteString)-downsampled-\(size)"
    let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
    
    self.kf.setImage(
      with: resource,
      placeholder: placeholder,
      options: [
        .processor(size.processor),
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage
      ],
      completionHandler: completionHandler
    )
  }
}
