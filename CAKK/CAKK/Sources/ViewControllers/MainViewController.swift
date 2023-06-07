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

import FloatingPanel

final class MainViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constants {
    static let refreshButtonText: String = "새로 고침"
  }
  
  enum Metric {
    static let horizontalPadding = 16.f
    static let verticalPadding = 24.f
    
    static let cakkMapBottomInset = 10.f
    
    static let bottomSheetTipModeHeight = 58.f
    
    static let cakeShopPopupViewBottomInset = 12.f
    static let cakeShopPopupViewHeight = 158.f
  }
  
  
  // MARK: - Properties
  
  private let viewModel: MainViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  private var cakeShopPopupView: CakeShopPopUpView?
  
  private let cakeShopListSurfaceAppearance = SurfaceAppearance().then { appearance in
    appearance.cornerRadius = 20
    
    // Shadows
    let shadow = SurfaceAppearance.Shadow()
    shadow.color = UIColor.black
    shadow.offset = CGSize(width: 0, height: -8)
    shadow.radius = 20
    shadow.spread = 8
    shadow.opacity = 0.1
    appearance.shadows = [shadow]
  }
  
  
  // MARK: - UI
  
  private let cakkMapView = CakkMapView(frame: .zero)
  
  private lazy var cakeShopListFloatingPanel = FloatingPanelController().then {
    $0.layout = CakeShopListFloatingPanelLayout()
    $0.surfaceView.appearance = cakeShopListSurfaceAppearance
    $0.surfaceView.grabberHandlePadding = 12
  }
  
  private let refreshButton = CapsuleStyleLoadingButton(
    iconImage: R.image.refresh(),
    loadingIconImage: UIImage(systemName: "ellipsis"),
    title: "이 지역 재검색",
    loadingTitle: "로딩 중...").then {
      $0.isEnabled = false
      $0.backgroundColor = UIColor(hex: 0x4963E9)
    $0.addShadow(to: .bottom)
  }
  
  private lazy var currentLocationButton = UIButton().then {
    $0.setImage(R.image.scope(), for: .normal)
    $0.imageEdgeInsets = UIEdgeInsets(common: 10)
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.addShadow(to: .bottom)
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupLayouts()
    setupView()
    setupLocationManager()
    
    bind(viewModel)
  }
  
  // Setup Layout
  private func setupLayouts() {
    setupNaverMapViewLayout()
    setupRefreshButtonLayout()
    setupLocationButtonLayout()
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
      $0.width.equalTo(120)
    }
  }
  
  private func setupLocationButtonLayout() {
    view.addSubview(currentLocationButton)
    currentLocationButton.snp.makeConstraints {
      $0.width.height.equalTo(40)
      $0.centerY.equalTo(refreshButton)
      $0.trailing.equalToSuperview().inset(20)
    }
  }
  
  // Setup View
  private func setupView() {
    setupBaseView()
    setupMapView()
    setupCakeShopListFloatingPanel()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
  }
  
  private func setupMapView() {
    cakkMapView.mapView.addCameraDelegate(delegate: self)
    cakkMapView.didTappedMarker = { [weak self] cakeShop in
      self?.showCakeShopPopupView(cakeShop)
    }
    cakkMapView.didUnselectMarker = { [weak self] in
      self?.hideCakeShopPopupView()
    }
  }
  
  private func setupCakeShopListFloatingPanel() {
    cakeShopListFloatingPanel.set(contentViewController: .init())
    cakeShopListFloatingPanel.addPanel(toParent: self)
    cakeShopListFloatingPanel.delegate = self
  }
  
  // Setup ETC
  private func setupLocationManager() {
    LocationDataManager.shared.didChangeAuthorization
      .sink { [weak self] status in
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.viewModel.loadMyFinalPosition()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
              self?.loadInitialCakeShops()
            }
          }
        case .denied, .restricted:
          self?.viewModel.setSelectedDistrict()
        default:
          break
        }
      }
      .store(in: &cancellableBag)
  }
  
  // Bind
  private func bind(_ viewModel: MainViewModel) {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    currentLocationButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] _ in
        guard let self = self else { return }
        switch LocationDataManager.shared.authorizationStatus {
          // 권한 부여 상태: 현재 위치로 지도 카메라 이동
        case .authorizedAlways, .authorizedWhenInUse:
          self.cakkMapView.moveCameraToCurrentPosition()
          // 권한 미부여 상태: 설정으로 이동하게 유도
        default:
          self.askUserToPermissionSetting()
        }
      }
      .store(in: &cancellableBag)
    
    refreshButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .compactMap { [weak self] in self?.cakkMapView.mapView.contentBounds }
      .sink { [weak self] bounds in
        self?.viewModel.input.searchByMapBounds.send(bounds)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output
      .cakeShops
      .sink { [weak self] cakeShops in
        if cakeShops.isEmpty == false {
          self?.showCakeShopListFloatingPanel(cakeShops)
        }
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .cameraCoordinates
      .sink { [weak self] coordinate in
        self?.cakkMapView.moveCamera(
          .init(lat: coordinate.latitude, lng: coordinate.longitude),
          zoomLevel: 12)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .showDistrictSelectionView
      .sink { [weak self] _ in
        self?.showChangeDistrictView()
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .loadingCakeShops
      .sink { [weak self] isLoading in
        if isLoading {
          self?.refreshButton.status = .loading
          self?.hideCakeShopPopupView { [weak self] in
            self?.cakeShopListFloatingPanel.move(to: .hidden, animated: true)
          }
        } else {
          self?.refreshButton.status = .done
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func showCakeShopPopupView(_ cakeShop: CakeShop) {
    let newCakeShopPopupView = CakeShopPopUpView(cakeShop: cakeShop)
    view.insertSubview(newCakeShopPopupView, aboveSubview: cakeShopPopupView ?? cakkMapView)
    newCakeShopPopupView.snp.makeConstraints {
      $0.bottom.equalTo(cakeShopListFloatingPanel.surfaceView.snp.top).inset(-Metric.cakeShopPopupViewBottomInset)
      $0.height.equalTo(Metric.cakeShopPopupViewHeight)
      $0.width.equalTo(cakeShopListFloatingPanel.surfaceView).inset(Metric.horizontalPadding)
      $0.centerX.equalTo(cakeShopListFloatingPanel.surfaceView)
    }
    view.layoutIfNeeded()

    applyAnimation(to: newCakeShopPopupView)

    newCakeShopPopupView.shareButtonTapHandler = { [weak self] in
      let items = [cakeShop.name, cakeShop.location, cakeShop.url]

      let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
      activity.modalPresentationStyle = .popover
      activity.popoverPresentationController?.sourceView = newCakeShopPopupView.shareButton
      self?.present(activity, animated: true)
    }

    hideCakeShopPopupView { [weak self] in
      self?.cakeShopPopupView = newCakeShopPopupView
    }
    
    cakeShopListFloatingPanel.move(to: .tip, animated: true)
  }
  
  private func showCakeShopListFloatingPanel(_ cakeShops: [CakeShop]) {
    let viewController = DIContainer.shared.makeCakeShopListViewController(initialCakeShops: cakeShops)
    viewController.cakeShopItemSelectAction = { [weak self] cakeShop in
      let coordinate = NMGLatLng(lat: cakeShop.latitude, lng: cakeShop.longitude)
      self?.cakkMapView.moveCamera(coordinate, zoomLevel: nil)
      self?.showCakeShopPopupView(cakeShop)
      self?.cakeShopListFloatingPanel.move(to: .tip, animated: true)
    }
    cakkMapView.bind(to: viewController.viewModel)
    
    cakeShopListFloatingPanel.set(contentViewController: viewController)
    cakeShopListFloatingPanel.track(scrollView: viewController.collectionView)
    cakeShopListFloatingPanel.move(to: .tip, animated: true)
  }
  
  private func applyAnimation(to popupView: CakeShopPopUpView) {
    var startTransform = CGAffineTransform.identity
    startTransform = startTransform.scaledBy(x: 0.8, y: 0.8)
    startTransform = startTransform.translatedBy(x: 0, y: Metric.cakeShopPopupViewHeight) /// height만큼 내림
    popupView.transform = startTransform
    popupView.alpha = 0
    
    var endTransform = CGAffineTransform.identity
    endTransform = endTransform.scaledBy(x: 1, y: 1)
    endTransform = endTransform.translatedBy(x: 0, y: 0)
    
    UIView.animate(
      withDuration: 0.6,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 0.7) {
        popupView.transform = endTransform
        popupView.alpha = 1
      }
  }
  
  private func hideCakeShopPopupView(_ completion: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.2) { [weak self] in
      self?.cakeShopPopupView?.transform = .init(translationX: 0, y: -20)
    } completion: { [weak self] _ in
      UIView.animate(withDuration: 0.2) { [weak self] in
        self?.cakeShopPopupView?.transform = .init(translationX: 0, y: Metric.cakeShopPopupViewHeight)
        self?.cakeShopPopupView?.alpha = 0
      } completion: { [weak self] _ in
        self?.cakeShopPopupView?.removeFromSuperview()
        completion?()
      }
    }
  }
  
  private func showChangeDistrictView() {
    let viewController = DIContainer.shared.makeDistrictSelectionController()
    viewController.modalPresentationStyle = .fullScreen
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.present(viewController, animated: true)
    }
  }
  
  private func askUserToPermissionSetting() {
    showAskAlert(title: "위치 권한이 필요해요",
                 message: "현재 내 위치로 이동하기 위해 권한이 필요해요.\n설정에서 위치 권한을 허용 해주세요",
                 completion: { isConfirmed in
      guard isConfirmed else { return }
      self.moveUserToSetting()
    })
  }
  
  private func moveUserToSetting() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(settingsURL)
  }
  
  private func loadInitialCakeShops() {
    let mapBounds = cakkMapView.mapView.contentBounds
    
    viewModel.input
      .searchByMapBounds
      .send(mapBounds)
  }
}


// MARK: - MapView Extensions

extension MainViewController: NMFMapViewCameraDelegate {
  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    if viewModel.output.loadingCakeShops.value == false {
      refreshButton.isEnabled = true
    }
    
    if reason == NMFMapChangedByGesture {
      cakeShopListFloatingPanel.move(to: .tip, animated: true)
    }
  }
  
  func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
    refreshButton.isEnabled = true
    
    // Save my last position
    guard reason == NMFMapChangedByGesture else { return }
    
    let coordinates = Coordinates(
      latitude: mapView.cameraPosition.target.lat,
      longitude: mapView.cameraPosition.target.lng)
    
    viewModel.input
      .cameraMove
      .send(coordinates)
  }
}

// MARK: - FloatingPanelControllerDelegate

extension MainViewController: FloatingPanelControllerDelegate {
  func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
    if newCollection.verticalSizeClass == .compact {
      return CakeShopListFloatingPanelLandscapeLayout()
    }
    
    if newCollection.verticalSizeClass == .regular && newCollection.horizontalSizeClass == .regular {
      return CakeShopListFloatingPanelLandscapeLayout()
    }
    
    return CakeShopListFloatingPanelLayout()
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ViewControllerPreView: PreviewProvider {
  static var previews: some View {
    let viewModel = MainViewModel(districts: [.dobong, .dongdaemun], service: .init(type: .stub))
    MainViewController(viewModel: viewModel)
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
