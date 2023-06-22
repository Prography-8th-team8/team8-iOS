//
//  RefreshButton.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/04.
//

import UIKit

class RefreshButton: CapsuleStyleButton {
  
  // MARK: - Constants
  
  enum Status {
    case loading
    case done
  }
  
  // MARK: - Properties
  
  private let iconImage = R.image.refresh()
  private let loadingIconImage = UIImage(systemName: "ellipsis")
  
  private let title: String
  private let loadingTitle: String
  
  var status: Status = .done {
    didSet {
      updateByStatus()
    }
  }
  
  // MARK: - Initialization
  
  init(title: String,
       loadingTitle: String) {
    self.title = title
    self.loadingTitle = loadingTitle
    
    super.init(
      iconImage: iconImage,
      text: title,
      spacing: 4,
      horizontalPadding: 12,
      verticalPadding: 10)
    font = .pretendard(size: 12, weight: .bold)
    borderColor = .init(hex: 0x4963E9)
    borderWidth = 1
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func showWithAnimation() {
    if alpha == 0 {
      UIView.animate(withDuration: 0.3) {
        self.alpha = 1
      }
    }
  }
  
  public func hideWithAnimation() {
    if alpha == 1 {
      UIView.animate(withDuration: 0.3) {
        self.alpha = 0
      }
    }
  }
  
  
  // MARK: - Private
  
  private func updateByStatus() {
    switch status {
    case .loading:
      updateTitle(with: status)
      updateIconImage(with: status)
    case .done:
      // 버튼이 사라지기 전에 UI가 완료 상태로 업데이트 되지 않도록 0.2초 지연을 줌
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.updateTitle(with: self.status)
        self.updateIconImage(with: self.status)
      }
    }
  }
  
  private func updateIconImage(with status: Status) {
    let iconImage = status == .loading ? loadingIconImage : iconImage
    UIView.transition(with: iconImageView,
                      duration: 0.3,
                      options: .transitionFlipFromLeft) {
      self.iconImageView.image = iconImage
    }
  }
  
  private func updateTitle(with status: Status) {
    let buttonTitle = status == .loading ? loadingTitle : title
    UIView.transition(with: buttonLabel,
                      duration: 0.3,
                      options: .transitionFlipFromLeft) {
      self.buttonLabel.text = buttonTitle
    }
  }
}
