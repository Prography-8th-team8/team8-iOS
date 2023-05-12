//
//  MainViewController.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit

import Combine
import CombineCocoa

import SnapKit
import Then

import NMapsMap

import BottomSheetView

final class MainViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constants {
    static let refreshButtonText: String = "새로 고침"
    static let seeLocationButtonText: String = "지도 보기"
  }
  
  enum Metric {
    static let horizontalPadding = 16.f
    static let verticalPadding = 24.f
    
    static let naverMapViewHeightRatio = 0.5
    static let naverMapBottomInset = 10.f

    static let seeLocationButtonBottomInset = 28.f
    
    static let bottomSheetTipModeHeight = 58.f
    
    static let hideDetailBottomSheetButtonSize = 40.f
    static let hideDetailBottomSheetButtonCornerRadius = 20.f
  }

  
  // MARK: - Properties

  private var cancellableBag = Set<AnyCancellable>()
  static let cakeShopListBottomSheetLayout = BottomSheetLayout(
    half: .fractional(0.5),
    tip: .absolute(CakeListViewController.Metric.headerViewHeight))
  static let cakeShopDetailBottomSheetLayout = BottomSheetLayout(
    tip: .absolute(280)) // 임시로 safeArea보다 아래로 내려가게 설정 - BottomSheetView 기능 수정되면 변경 예정
  
  // MARK: - UI
  
  private let naverMapView = NMFNaverMapView(frame: .zero).then {
    $0.showZoomControls = false
    $0.mapView.logoAlign = .rightTop
  }
  
//  private let refreshButton = CapsuleStyleButton(
//    iconImage: UIImage(systemName: "arrow.clockwise")!,
//    text: Constants.refreshButtonText
//  )
  
  private lazy var seeLocationButton = CapsuleStyleButton(
    iconImage: UIImage(systemName: "map")!,
    text: Constants.seeLocationButtonText
  ).then {
    $0.isHidden = true
    $0.addTarget(self, action: #selector(seeLocation), for: .touchUpInside)
  }

  private let cakeShopListBottomSheet = BottomSheetView().then {
    $0.layout = MainViewController.cakeShopListBottomSheetLayout
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.1
    $0.layer.shadowRadius = 20
    $0.layer.shadowOffset = .zero
  }
  private let cakeListViewController = CakeListViewController()
  
  private let cakeShopDetailBottomSheet = BottomSheetView().then {
    $0.layout = MainViewController.cakeShopDetailBottomSheetLayout
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.1
    $0.layer.shadowRadius = 20
    $0.layer.shadowOffset = .zero
  }
  
  private let hideDetailBottomSheetButton = UIButton().then {
    $0.backgroundColor = .white
    $0.tintColor = .black
    $0.layer.borderColor = UIColor(hex: 0x222222).withAlphaComponent(0.1).cgColor
    $0.layer.borderWidth = 1
    $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    $0.alpha = 0
  }
  
  private var isTableViewPanning: Bool = false

  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }


  // MARK: - Private
  
  private func setup() {
    setupLayouts()
    setupView()
    bind()
  }
  
  private func setupLayouts() {
    setupNaverMapViewLayout()
//    setupRefreshButtonLayout()
    setupHideDetailBottomSheetButtonLayout()
  }
  
  private func setupNaverMapViewLayout() {
    view.addSubview(naverMapView)
    naverMapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
//  private func setupRefreshButtonLayout() {
//    view.addSubview(refreshButton)
//    refreshButton.snp.makeConstraints {
//      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Metric.verticalPadding)
//      $0.centerX.equalToSuperview()
//    }
//  }
  
  private func setupHideDetailBottomSheetButtonLayout() {
    view.addSubview(hideDetailBottomSheetButton)
    hideDetailBottomSheetButton.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
      $0.top.equalToSuperview().inset(Metric.verticalPadding)
      $0.width.height.equalTo(Metric.hideDetailBottomSheetButtonSize)
    }
    
    hideDetailBottomSheetButton.layer.cornerRadius = Metric.hideDetailBottomSheetButtonCornerRadius
  }
  
  private func setupView() {
    setupBaseView()
    setupMapView()
    setupSeeLocationButton()
    setupCakeShopListBottomSheet()
    setupCakeShopListViewController()
    setupCakeShopDetailBottomSheet()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
  }
  
  private func setupMapView() {
    naverMapView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func setupSeeLocationButton() {
    view.addSubview(seeLocationButton)
    seeLocationButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(Metric.seeLocationButtonBottomInset)
    }
  }
  
  private func setupCakeShopListBottomSheet() {
    // Configuration
    cakeShopListBottomSheet.configure(
      parentViewController: self,
      contentViewController: cakeListViewController
    )
    
    // Appearance
    var appearance = BottomSheetAppearance()
    appearance.fillSafeAreaWhenPositionAtFull = true
    cakeShopListBottomSheet.appearance = appearance
    
    
    // Layout
    cakeShopListBottomSheet.snp.makeConstraints {
      $0.top.equalTo(naverMapView.snp.bottom)
        .inset(Metric.naverMapBottomInset)
        .priority(.low)
    }
  }
  
  private func setupCakeShopListViewController() {
    cakeListViewController.cakeShopItemSelectAction = { [weak self] in
      self?.showCakeShopDetail()
    }
  }
  
  private func setupCakeShopDetailBottomSheet() {
    // Configuration
    cakeShopDetailBottomSheet.configure(
      parentViewController: self,
      contentViewController: .init())
    
    // Appearance
    var appearance = BottomSheetAppearance()
    appearance.fillSafeAreaWhenPositionAtFull = true
    cakeShopDetailBottomSheet.appearance = appearance
    
    cakeShopDetailBottomSheet.hide()
  }
  
  private func bind() {
    bindHideCakeShopDetailButton()
  }
  
  private func bindHideCakeShopDetailButton() {
    hideDetailBottomSheetButton.tapPublisher
      .sink { [weak self] _ in
        self?.hideCakeShopDetail()
      }
      .store(in: &cancellableBag)
  }
  
  @objc private func seeLocation() {
    cakeShopListBottomSheet.move(to: .half)
  }
  
  private func showCakeShopDetail() {
    cakeShopListBottomSheet.hide()
    cakeShopDetailBottomSheet.show(.half)

    UIView.animate(withDuration: 0.3) {
      self.hideDetailBottomSheetButton.alpha = 1
    }
  }

  private func hideCakeShopDetail() {
    cakeShopListBottomSheet.show()
    cakeShopDetailBottomSheet.hide()
    
    UIView.animate(withDuration: 0.3) {
      self.hideDetailBottomSheetButton.alpha = 0
    }
  }
}

// MARK: - MapView Extensions

extension MainViewController: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    cakeShopListBottomSheet.move(to: .tip)
  }
}

// MARK: - Preview

import SwiftUI

struct ViewControllerPreView: PreviewProvider {
  static var previews: some View {
    MainViewController()
      .toPreview()
      .ignoresSafeArea()
  }
}
