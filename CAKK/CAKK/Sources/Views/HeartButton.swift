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
  }
  
  
  // MARK: - Public
  
  public func setBookmark(_ state: Bool) {
    if isBookmarked {
      setImage(R.image.heart_filled(), for: .normal)
    } else {
      setImage(R.image.heart(), for: .normal)
    }
  }
}
