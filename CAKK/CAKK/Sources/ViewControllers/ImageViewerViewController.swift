//
//  ImageViewerViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/14.
//

import UIKit

import SnapKit
import Then
import Hero

class ImageViewerViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let maximumZoomScale = 10.f
    static let minimumZoomScale = 1.f
  }
  
  
  // MARK: - Properties
  
  private let imageUrl: String
  
  
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
  private let dimmingView = UIVisualEffectView().then { view in
    let effect = UIBlurEffect(style: .light)
    view.effect = effect
  }
  
  
  // MARK: - Initializers
  
  init(imageUrl: String) {
    self.imageUrl = imageUrl
    super.init(nibName: nil, bundle: nil)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startLoading()
  }
  
  
  // MARK: - Private
  
  @objc
  private func didPan(_ sender: UIPanGestureRecognizer) {
    let translate = sender.translation(in: view)
    let distanceY = abs(view.frame.origin.y - abs(imageView.frame.origin.y))
    let velocity = sender.velocity(in: view)
    let dismissThreshold = 160.f
    
    if distanceY > dismissThreshold {
      imageView.frame.origin.x += translate.x * 0.65
      imageView.frame.origin.y += translate.y * 0.65
    } else {
      imageView.frame.origin.x += translate.x
      imageView.frame.origin.y += translate.y
    }
    
    if sender.state == .ended {
      if distanceY > dismissThreshold ||
          abs(velocity.x) > 100 ||
          abs(velocity.y) > 100 {
        dismiss(animated: true)
      } else {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8) {
          self.imageView.frame.origin = self.view.frame.origin
        }
      }
    }
    
    sender.setTranslation(.zero, in: view)
  }
  
  @objc
  private func didTap(_ sender: UITapGestureRecognizer) {
    dismiss(animated: true)
  }
  
  private func startLoading() {
    loadingView.startAnimating()
  }
  
  private func stopLoading() {
    loadingView.stopAnimating()
    loadingView.removeFromSuperview()
  }
}


// MARK: - UI & Layout

extension ImageViewerViewController {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupDimmingViewLayout()
    setupLoadingViewLayout()
    setupScrollViewLayout()
    setupImageViewLayout()
  }
  
  private func setupDimmingViewLayout() {
    view.addSubview(dimmingView)
    dimmingView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupLoadingViewLayout() {
    view.addSubview(loadingView)
    loadingView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupScrollViewLayout() {
    view.addSubview(scrollView)
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
  
  private func setupView() {
    setupBaseView()
    setupImageView()
    setupDimmingView()
  }
  
  private func setupBaseView() {
    hero.isEnabled = true
    view.backgroundColor = .clear
  }
  
  private func setupImageView() {
    let url = URL(string: imageUrl)
    imageView.kf.setImage(with: url) { [weak self] result in
      guard let self else { return }
      self.stopLoading()
      
      do {
        try result.get()
      } catch {
        self.imageView.image = R.image.no_img_square()
      }
    }
    
    // hero
    imageView.hero.modifiers = [.scale(0.5), .duration(0.25)]
    
    // pan gesture
    imageView.isUserInteractionEnabled = true
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
    imageView.addGestureRecognizer(panGestureRecognizer)
  }
  
  private func setupDimmingView() {
    // tap gesture
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
    dimmingView.addGestureRecognizer(tapGestureRecognizer)
    
    // hero animation
    dimmingView.isHeroEnabled = true
    dimmingView.hero.modifiers = [.fade, .duration(0.25)]
  }
}


// MARK: - UIScrollView Delegate

extension ImageViewerViewController: UIScrollViewDelegate {
  
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


// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ImageViewerViewController_Preview: PreviewProvider {
  
  static var previews: some View {
    ZStack {
      VStack {
        Text("Hello word")
        
        Spacer()
      }
      .padding(24)
      
      let imageUrl = "https://bucket-8th-team8.s3.ap-northeast-2.amazonaws.com/cakk/store/f26fe985-c10e-463c-8793-4fffe13ae2ef.jpeg"
      ImageViewerViewController(imageUrl: imageUrl).toPreview()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
  }
}
#endif
