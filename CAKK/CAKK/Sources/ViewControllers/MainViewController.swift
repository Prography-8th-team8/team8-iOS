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
    
    static let cakkMapBottomInset = 10.f

    static let seeLocationButtonBottomInset = 28.f
    
    static let bottomSheetTipModeHeight = 58.f
    
    static let hideDetailBottomSheetButtonSize = 40.f
    static let hideDetailBottomSheetButtonCornerRadius = 20.f
  }

  
  // MARK: - Properties

  private let viewModel: MainViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  static let cakeShopListBottomSheetLayout = BottomSheetLayout(
    half: .fractional(0.5),
    tip: .absolute(CakeShopListViewController.Metric.headerViewHeight))
  
  static let cakeShopDetailBottomSheetLayout = BottomSheetLayout(
    tip: .absolute(280)) // 임시로 safeArea보다 아래로 내려가게 설정 - BottomSheetView 기능 수정되면 변경 예정
  
  private var bottomSheetAppearance: BottomSheetAppearance {
    var appearance = BottomSheetAppearance()
    appearance.shadowColor = UIColor.black.cgColor
    appearance.shadowOpacity = 0.1
    appearance.shadowRadius = 20
    appearance.shadowOffset = .init(width: 0, height: -8)
    appearance.ignoreSafeArea = [.top]
    
    return appearance
  }
  
  private var isDetailViewShown = false {
    didSet {
      let alpha = isDetailViewShown ? 1.f : 0.f
      UIView.animate(withDuration: 0.3) {
        self.hideDetailBottomSheetButton.alpha = alpha
      }
    }
  }
  
  private var shopDetailViewController: ShopDetailViewController?
  
  
  // MARK: - UI
  
  private let cakkMapView = CakkMapView(frame: .zero)
  
  private lazy var seeLocationButton = CapsuleStyleButton(
    iconImage: UIImage(systemName: "map")!,
    text: Constants.seeLocationButtonText
  ).then {
    $0.isHidden = true
    $0.addTarget(self, action: #selector(seeLocation), for: .touchUpInside)
  }

  private let cakeShopListBottomSheet = BottomSheetView().then {
    $0.layout = MainViewController.cakeShopListBottomSheetLayout
  }
  private var cakeListViewController: CakeShopListViewController?
  
  private let cakeShopDetailBottomSheet = BottomSheetView().then {
    $0.layout = MainViewController.cakeShopDetailBottomSheetLayout
  }
  
  private let hideDetailBottomSheetButton = UIButton().then {
    $0.backgroundColor = .white
    $0.tintColor = .black
    $0.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
    $0.layer.borderWidth = 1
    $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    $0.alpha = 0
  }
  
  private let refreshButton = CapsuleStyleButton(
    iconImage: UIImage(systemName: "arrow.counterclockwise") ?? .init(),
    text: "이 지역 재검색"
  ).then {
    $0.isEnabled = false
  }
  
  private var isTableViewPanning: Bool = false

  
  // MARK: - LifeCycle
  
  init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }


  // MARK: - Private
  
  private func setup() {
    setupLayouts()
    setupView()
    
    bind(viewModel)
  }
  
  // Setup Layout
  private func setupLayouts() {
    setupNaverMapViewLayout()
    setupRefreshButtonLayout()
    setupHideDetailBottomSheetButtonLayout()
  }
  
  private func setupNaverMapViewLayout() {
    view.addSubview(cakkMapView)
    cakkMapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupRefreshButtonLayout() {
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Metric.verticalPadding)
    }
  }
  
  private func setupHideDetailBottomSheetButtonLayout() {
    view.addSubview(hideDetailBottomSheetButton)
    hideDetailBottomSheetButton.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
      $0.centerY.equalTo(refreshButton)
      $0.width.height.equalTo(Metric.hideDetailBottomSheetButtonSize)
    }
    
    hideDetailBottomSheetButton.layer.cornerRadius = Metric.hideDetailBottomSheetButtonCornerRadius
  }
  
  // Setup View
  private func setupView() {
    setupBaseView()
    setupMapView()
    setupSeeLocationButton()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
  }
  
  private func setupMapView() {
    cakkMapView.mapView.addCameraDelegate(delegate: self)
    cakkMapView.didTappedMarker = { [weak self] cakeShop in
      self?.showCakeShopDetail(cakeShop)
    }
    cakkMapView.didUnselectMarker = { [weak self] in
      self?.hideCakeShopDetail()
    }
  }
  
  private func setupSeeLocationButton() {
    view.addSubview(seeLocationButton)
    seeLocationButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(Metric.seeLocationButtonBottomInset)
    }
  }
  
  // Bind
  private func bind(_ viewModel: MainViewModel) {
    hideDetailBottomSheetButton.tapPublisher
      .sink { [weak self] _ in
        self?.hideCakeShopDetail()
        self?.cakkMapView.unselectMarker()
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .cakeShops
      .sink { [weak self] cakeShops in
        if cakeShops.isEmpty == false {
          self?.showCakeShopList(cakeShops)
        }
      }
      .store(in: &cancellableBag)
  }
  
  @objc private func seeLocation() {
    cakeShopListBottomSheet.move(to: .half)
  }
  
  private func showCakeShopList(_ cakeShops: [CakeShop]) {
    let cakeListViewController = DIContainer.shared.makeCakeShopListViewController(initialCakeShops: cakeShops)
    cakkMapView.bind(to: cakeListViewController.viewModel)
    
    cakeListViewController.cakeShopItemSelectAction = { [weak self] cakeShop in
      self?.showCakeShopDetail(cakeShop)
    }
    self.cakeListViewController = cakeListViewController
    
    // Configuration
    cakeShopListBottomSheet.configure(
      parentViewController: self,
      contentViewController: cakeListViewController
    )
    
    // Layout
    cakeShopListBottomSheet.snp.makeConstraints {
      $0.top.equalTo(cakkMapView.snp.bottom)
        .inset(Metric.cakkMapBottomInset)
        .priority(.low)
    }
    
    // Appearance
    cakeShopListBottomSheet.appearance = bottomSheetAppearance
  }
  
  private func showCakeShopDetail(_ cakeShop: CakeShop) {
    hideCakeShopDetail()
    
    let shopDetailViewController = DIContainer.shared.makeShopDetailViewController(with: cakeShop)
    self.shopDetailViewController = shopDetailViewController
    
    cakeShopDetailBottomSheet.configure(
      parentViewController: self,
      contentViewController: shopDetailViewController)
    
    cakeShopDetailBottomSheet.appearance = bottomSheetAppearance
    
    shopDetailViewController.notifyViewWillShow()
    cakeShopListBottomSheet.hide()
    cakeShopDetailBottomSheet.show(.half)
    isDetailViewShown = true
  }

  private func hideCakeShopDetail() {
    cakeShopListBottomSheet.show()
    cakeShopDetailBottomSheet.hide()
    isDetailViewShown = false
  }
}

// MARK: - MapView Extensions

extension MainViewController: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    if isDetailViewShown == false {
      cakeShopListBottomSheet.move(to: .tip)
    }
  }
}

// MARK: - Preview

import SwiftUI

struct ViewControllerPreView: PreviewProvider {
  static var previews: some View {
    let viewModel = MainViewModel(districts: [.dobong, .dongdaemun], service: .init(type: .stub))
    MainViewController(viewModel: viewModel)
      .toPreview()
      .ignoresSafeArea()
  }
}
