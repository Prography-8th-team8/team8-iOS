//
//  ImageViewerCollectionCell.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/02.
//

import UIKit

import Then
import SnapKit

import Kingfisher

class ImageViewerCollectionCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  static let id = String(describing: ImageViewerCollectionCell.self)
  
  enum Metric {
    static let maximumZoomScale = 10.f
    static let minimumZoomScale = 1.f
  }


  // MARK: - Properties
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - UI
  
  private lazy var scrollView = UIScrollView().then {
    $0.delegate = self
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.maximumZoomScale = Metric.maximumZoomScale
    $0.minimumZoomScale = Metric.minimumZoomScale
  }
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  private let loadingView = UIActivityIndicatorView().then {
    $0.stopAnimating()
  }
  private let failureLabel = UILabel().then {
    $0.text = "이미지 불러오기에 실패하였습니다"
    $0.font = .pretendard(size: 15, weight: .semiBold)
    $0.textColor = R.color.gray_60()
  }
  
  
  // MARK: - Configure
  
  public func configure(imageUrl: String) {
    startLoading()
    
    let url = URL(string: imageUrl)
    imageView.kf.setImage(with: url) { [weak self] result in
      self?.stopLoading()
      
      do {
        try result.get()
      } catch {
        self?.showFilaureLabel()
      }
    }
  }
  
  private func startLoading() {
    loadingView.isHidden = false
    loadingView.startAnimating()
  }
  
  private func stopLoading() {
    loadingView.isHidden = true
    loadingView.stopAnimating()
  }
  
  private func showFilaureLabel() {
    failureLabel.removeFromSuperview()
    contentView.addSubview(failureLabel)
    failureLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}


// MARK: - UI & Layout

extension ImageViewerCollectionCell {
  
  private func setup() {
    setupLayout()
  }
  
  private func setupLayout() {
    setupScrollViewLayout()
    setupImageViewLayout()
    setupLoadingViewLayout()
  }
  
  private func setupScrollViewLayout() {
    contentView.addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupImageViewLayout() {
    scrollView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
      $0.height.equalToSuperview()
    }
  }
  
  private func setupLoadingViewLayout() {
    contentView.addSubview(loadingView)
    loadingView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}


// MARK: - UIScrollView Delegate

extension ImageViewerCollectionCell: UIScrollViewDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    UIView.animate(withDuration: 0.4,
                   delay: 0,
                   usingSpringWithDamping: 0.9,
                   initialSpringVelocity: 0.9) {
      self.scrollView.zoomScale = 1.0
    }
  }
}
