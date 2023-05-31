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

    static let descriptionLabelFontSize = 16.f
    static let descriptionLabelInset = 12.f
  }
  
  
  // MARK: - Properties
  
  private var locationManager: CLLocationManager?
  
  
  // MARK: - UI
  
  private var gridAnimations = [LottieAnimationView]()
  private var animationStackView = UIStackView().then {
    $0.spacing = Metric.gridAnimationSpacing
    $0.axis = .vertical
    $0.distribution = .fillEqually
  }
  private var logoStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = Metric.logoStackViewSpacing
  }
  private var descriptionContainerView = UIView().then {
    $0.backgroundColor = .white.withAlphaComponent(0.2)
    $0.layer.cornerRadius = 20
  }
  private var descriptionLabel = UILabel().then {
    $0.font = .pretendard(size: Metric.descriptionLabelFontSize, weight: .bold)
    $0.text = Constants.description
    $0.textColor = .white
  }
  private var logoImageView = UIImageView().then {
    $0.image = R.image.logo()
    $0.contentMode = .scaleAspectFill
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    playAnimations()
    requestLocationPermission()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stopAnimations()
  }
  
  
  // MARK: - Public
  
  public func startSplash(completion: @escaping () -> Void) {
    playAnimations()
    
    DispatchQueue.main.asyncAfter(
      deadline: .now() + Constants.splashDuration,
      execute: .init(block: {
        completion()
      }))
  }
  
  public func playAnimations() {
    gridAnimations.forEach { animationView in
      animationView.play()
    }
  }
  
  public func stopAnimations() {
    gridAnimations.forEach { animationView in
      animationView.stop()
    }
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupLocationManager()
    
    setupLayout()
    setupView()
  }
  
  private func setupLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
  }
  
  private func setupLayout() {
    setupAnimationStackViewLayout()
    setupAnimationViewLayout()
    
    setupLogoStackViewLayout()
    setupLogoImageViewLayout()
    
    setupDescriptionContainerViewLayout()
    setupDescriptionLabelLayout()
  }
  
  private func setupAnimationStackViewLayout() {
    view.addSubview(animationStackView)
    animationStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupAnimationViewLayout() {
    /// 애니메이션 가로 비율이 더 길어서 가로로 여러번 붙여 그리드 사이즈 문제 해결
    for _ in 0...5 {
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
    logoStackView.addArrangedSubview(descriptionContainerView)
  }
  
  private func setupDescriptionLabelLayout() {
    descriptionContainerView.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(Metric.descriptionLabelInset)
    }
  }

  private func setupView() {
    setupBaseView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = UIColor(named: "AccentColor")
  }
  
  private func requestLocationPermission() {
    locationManager?.requestWhenInUseAuthorization()
  }
  
  private func replaceRoot(viewController: UIViewController) {
    if let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
      keyWindow.switchRootViewController(viewController)
    }
  }
}

extension UIWindow {
  func switchRootViewController(_ viewController: UIViewController, animated: Bool = true, duration: TimeInterval = 0.5, options: UIView.AnimationOptions = .curveEaseInOut, completion: (() -> Void)? = nil) {
    guard animated else {
      rootViewController = viewController
      return
    }
    
    UIView.transition(with: self, duration: duration, options: options, animations: {
      let oldState = UIView.areAnimationsEnabled
      UIView.setAnimationsEnabled(false)
      self.rootViewController = viewController
      UIView.setAnimationsEnabled(oldState)
    }, completion: { _ in
      completion?()
    })
  }
}

extension SplashViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      // 권한 허용시 메인 뷰컨으로 이동
      startSplash { [weak self] in
        self?.replaceRoot(viewController: DIContainer.shared.makeMainViewController())
      }
    case .denied, .restricted:
      // 권한 허용 안되면 지역 선택으로 이동
      startSplash { [weak self] in
        self?.replaceRoot(viewController: DIContainer.shared.makeOnboardingViewController())
      }
    case .notDetermined:
      break
    default:
      break
    }
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SplashViewPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let splashViewController = SplashViewController()
      return splashViewController.view
    }
    .ignoresSafeArea()
  }
}
#endif
