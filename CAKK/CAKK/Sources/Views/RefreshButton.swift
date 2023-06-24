//
//  RefreshButton.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/04.
//

import UIKit
import Then
import Lottie

class RefreshButton: UIButton {
  
  
  // MARK: - Constants
  
  enum Metric {
    static let imageSize = 20.f
    static let height = 40.f
    static let spacing = 4.f
    static let horizontalPadding = 12.f
    static let loadingViewSize = 36.f
  }
  
  
  // MARK: - Properties
  
  private let title = "이 지역 재검색"
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        iconImageView.alpha = 0.3
        label.alpha = 0.3
      } else {
        iconImageView.alpha = 1
        label.alpha = 1
      }
    }
  }
  
  override var intrinsicContentSize: CGSize {
    return .init(
      width: label.intrinsicContentSize.width + Metric.spacing + Metric.horizontalPadding * 2,
      height: Metric.height)
  }
  
  
  // MARK: - UI
  
  private let iconImageView = UIImageView().then {
    $0.image = R.image.refresh()
    $0.tintColor = R.color.white()
  }
  
  private let label = UILabel().then {
    $0.textColor = R.color.white()
    $0.font = .pretendard(size: 12, weight: .bold)
  }
  
  private let loadingView = LottieAnimationView(name: "loading_dot").then {
    $0.contentMode = .scaleAspectFit
    $0.loopMode = .loop
    $0.alpha = 0
    $0.stop()
  }
  
  
  // MARK: - Initializers
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  
  // MARK: - Setup Layout
  
  private func setupLayout() {
    setupImageViewLayout()
    setupLabelLayout()
    setupLoadingViewLayout()
  }
  
  private func setupImageViewLayout() {
    addSubview(iconImageView)
    iconImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
      $0.width.height.equalTo(Metric.imageSize)
    }
  }
  
  private func setupLabelLayout() {
    addSubview(label)
    label.snp.makeConstraints {
      $0.centerY.equalTo(iconImageView.snp.centerY)
      $0.leading.equalTo(iconImageView.snp.trailing).offset(Metric.spacing)
      $0.trailing.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupLoadingViewLayout() {
    addSubview(loadingView)
    loadingView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(Metric.loadingViewSize)
    }
  }
  
  
  // MARK: - Setup View
  
  private func setupView() {
    setupBaseView()
    setupLabel()
  }
  
  private func setupBaseView() {
    backgroundColor = .init(hex: 0x4963E9)
    layer.borderWidth = 1
    layer.borderColor = UIColor(hex: 0x5B73EB).cgColor
    layer.cornerRadius = Metric.height / 2
    addShadow(to: .bottom)
  }
  
  private func setupLabel() {
    label.text = title
  }
  
  
  
  // MARK: - Public Method
  
  public func show() {
    UIView.animate(withDuration: 0.2) {
      self.alpha = 1
      self.transform = .init(scaleX: 1, y: 1)
    }
  }
  
  public func hide() {
    UIView.animate(withDuration: 0.15) {
      self.alpha = 0
      self.transform = .init(scaleX: 0.8, y: 0.8)
    } completion: { [weak self] _ in
      self?.stopLoading()
    }
  }
  
  public func startLoading() {
    loadingView.alpha = 1
    loadingView.play()
    
    label.text = ""
    iconImageView.alpha = 0
  }
  
  public func stopLoading() {
    loadingView.alpha = 0
    loadingView.stop()
    
    label.text = title
    iconImageView.alpha = 1
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct RefreshButton_Preview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      RefreshButton()
    }
  }
}
#endif
