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

class SplashViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constants {
    static let splashDuration = 2.f
    
    static let description = "위치 기반 스마트한 케이크샵 검색"
    
    // TODO: - 실제 애니메이션 제작 되면 cake_run 애니메이션 파일 삭제 필요.
    static let mockAnimationName = "cake_run"
  }

  enum Metric {
    static let animationViewSize = CGSize(width: 220, height: 220)
    static let descriptionLabelBottomMargin = 24.f
  }
  
  
  // MARK: - Properties
  
  
  // MARK: - UI
  
  private var animationView = LottieAnimationView(name: Constants.mockAnimationName).then {
    $0.loopMode = .loop
  }
  private var descriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .bold)
    $0.text = Constants.description
    $0.textColor = .white
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    animationView.stop()
  }
  
  
  // MARK: - Public
  
  public func startSplash(completion: @escaping () -> Void) {
    animationView.play()
    
    DispatchQueue.main.asyncAfter(
      deadline: .now() + Constants.splashDuration,
      execute: .init(block: {
        completion()
      }))
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupAnimationLayout()
    setupDescriptionLabelLayout()
  }
  
  private func setupAnimationLayout() {
    view.addSubview(animationView)
    animationView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(Metric.animationViewSize.width)
      $0.height.equalTo(Metric.animationViewSize.height)
    }
  }
  
  private func setupDescriptionLabelLayout() {
    view.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Metric.descriptionLabelBottomMargin)
      $0.centerX.equalToSuperview()
    }
  }
  
  private func setupView() {
    setupBaseView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = UIColor(named: "AccentColor")
  }
}
