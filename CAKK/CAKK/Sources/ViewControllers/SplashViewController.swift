//
//  SplashViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/04/07.
//

import UIKit

import Then
import SnapKit
import Lottie

import CoreLocation

class SplashViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constants {
    static let splashDuration = 1.5.f
    static let description = "위치 기반 스마트한 케이크샵 검색"
    static let animationName = "grid_animation"
  }
  
  enum Metric {
    static let descriptionLabelBottomMargin = 24.f
    static let gridAnimationSpacing = -18.f
    static let logoStackViewSpacing = 20.f
    
    static let subtitleLabelFontSize = 16.f
    static let subtitleLabelInset = 12.f
  }
  
  
  // MARK: - UI
  
  private var gridAnimations = [LottieAnimationView]()
  private lazy var animationStackView = UIStackView().then {
    $0.spacing = Metric.gridAnimationSpacing
    $0.axis = .vertical
    $0.distribution = .fillEqually
  }
  private var logoStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = Metric.logoStackViewSpacing
  }
  private var subtitleContainerView = UIView().then {
    $0.backgroundColor = .white.withAlphaComponent(0.2)
    $0.layer.cornerRadius = 20
    $0.alpha = 0
  }
  private var subtitleLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.subtitleLabelFontSize, weight: .bold)
    $0.text = Constants.description
    $0.textColor = .white
  }
  private var logoImageView = UIImageView().then {
    $0.image = R.image.logo()
    $0.contentMode = .scaleAspectFill
    $0.transform = .init(scaleX: 0, y: 0)
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    playAnimations()
  }
  
  
  // MARK: - Public
  
  public func startSplash(completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.splashDuration) {
      completion()
    }
  }
  
  public func playAnimations() {
    playGridAnimation()
    playLogoAnimation()
    playSubTitleAnimation()
  }
  
  public func stopAnimations() {
    stopGridAnimation()
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupAnimationStackViewLayout()
    setupAnimationViewLayout()
    
    setupLogoStackViewLayout()
    setupLogoImageViewLayout()
    
    setupDescriptionContainerViewLayout()
    setupSubtitleLabelLayout()
  }
  
  private func setupAnimationStackViewLayout() {
    view.addSubview(animationStackView)
    animationStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupAnimationViewLayout() {
    /// 애니메이션 가로 비율이 더 길어서 가로로 여러번 붙여 그리드 사이즈 문제 해결
    (0...5).forEach { _ in
      let animationView =  LottieAnimationView(name: Constants.animationName)
      animationView.contentMode = .scaleAspectFill
      animationView.loopMode = .loop
      gridAnimations.append(animationView)
    }
    
    gridAnimations.forEach { animationView in
      animationStackView.addArrangedSubview(animationView)
    }
  }
  
  private func setupLogoStackViewLayout() {
    view.addSubview(logoStackView)
    logoStackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupLogoImageViewLayout() {
    logoStackView.addArrangedSubview(logoImageView)
  }
  
  private func setupDescriptionContainerViewLayout() {
    logoStackView.addArrangedSubview(subtitleContainerView)
  }
  
  private func setupSubtitleLabelLayout() {
    subtitleContainerView.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(Metric.subtitleLabelInset)
    }
  }
  
  private func setupView() {
    setupBaseView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = UIColor(named: "AccentColor")
  }
  
  private func playGridAnimation() {
    gridAnimations.forEach { animationView in
      animationView.play()
    }
  }
  
  private func stopGridAnimation() {
    gridAnimations.forEach { animationView in
      animationView.stop()
    }
  }
  
  private func playLogoAnimation() {
    UIView.animate(withDuration: 0.7,
                   delay: 0,
                   usingSpringWithDamping: 0.7,
                   initialSpringVelocity: 0.7) {
      self.logoImageView.transform = .init(scaleX: 1, y: 1)
    }
  }
  
  private func playSubTitleAnimation() {
    UIView.animate(withDuration: 0.5) {
      self.subtitleContainerView.alpha = 1
    }
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SplashViewPreview: PreviewProvider {
  static var previews: some View {
    SplashViewController()
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
