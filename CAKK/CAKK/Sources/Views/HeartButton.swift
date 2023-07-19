//
//  HeartButton.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/19.
//

import UIKit

class HeartButton: UIButton {
  
  // MARK: - Properties
  
  public var isBookmarked: Bool
  
  
  // MARK: - Initializers
  
  init(isBookmarked: Bool) {
    self.isBookmarked = isBookmarked
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setup
  
  private func setup() {
    setupView()
  }
  
  private func setupView() {
    contentMode = .scaleAspectFit
    tintColor = R.color.gray_80()
    setBookmark(isBookmarked)
    
    addTarget(self, action: #selector(didFocus), for: .touchDown)
    addTarget(self, action: #selector(didRelease), for: .touchCancel)
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
  }
  
  
  // MARK: - Public
  
  public func setBookmark(_ state: Bool) {
    if state {
      setImage(R.image.heart_filled(), for: .normal)
      isBookmarked = true
    } else {
      setImage(R.image.heart(), for: .normal)
      isBookmarked = false
    }
  }
  
  
  // MARK: - Private
  
  @objc
  private func didFocus() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    UIView.animate(withDuration: 0.2) {
      self.transform = .init(scaleX: 0.8, y: 0.8)
    }
  }
  
  @objc
  private func didRelease() {
    UIView.animate(withDuration: 0.1) {
      self.transform = .init(scaleX: 0.8, y: 0.8)
    }
  }
  
  @objc
  private func didTap() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9) {
      self.transform = .init(scaleX: 1, y: 1)
    }
  }
}
