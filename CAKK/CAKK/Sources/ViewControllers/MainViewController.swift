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
import ToastPiston

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
    
    static let showMapButtonBottomInset = 20.f
  }
  
  
  // MARK: - Properties
  
  private let viewModel: MainViewModel
  private var cancellableBag = Set<AnyCancellable>()
  private let floatingPanelSurfaceAppearance = SurfaceAppearance().then { appearance in
    // Shadows
    let shadow = SurfaceAppearance.Shadow()
    shadow.color = UIColor.black
    shadow.offset = CGSize(width: 0, height: -8)
    shadow.radius = 20
    shadow.spread = 8
    shadow.opacity = 0.1
    appearance.shadows = [shadow]
    appearance.cornerRadius = 20
  }
  
  private var isLandscapeMode: Bool {
    let verticalSizeClass = traitCollection.verticalSizeClass
    let horizontalSizeClass = traitCollection.horizontalSizeClass
    
    if verticalSizeClass == .compact || (verticalSizeClass == .regular && horizontalSizeClass == .regular) {
      return true
    } else {
      return false
    }
  }
  
  
  // MARK: - UI
  
  private lazy var cakkMapView = CakkMapView(viewModel: self.viewModel).then {
    $0.mapView.addCameraDelegate(delegate: self)
  }
  
  private lazy var cakeShopListFloatingPanel = FloatingPanelController().then {
    $0.layout = CakeShopListFloatingPanelLayout()
    $0.surfaceView.appearance = floatingPanelSurfaceAppearance
    $0.surfaceView.grabberHandlePadding = 12
  }
  
  private lazy var cakeShopDetailFloatingPanel = FloatingPanelController().then {
    $0.layout = CakeShopDetailFloatingPanelLayout()
    $0.surfaceView.appearance = floatingPanelSurfaceAppearance
    $0.surfaceView.grabberHandle.isHidden = true
    $0.isRemovalInteractionEnabled = true
  }
  
  private lazy var filterFloatingPanel = FloatingPanelController().then {
    $0.layout = FilterFloatingPanelLayout()
    $0.surfaceView.appearance = floatingPanelSurfaceAppearance
    $0.surfaceView.grabberHandle.isHidden = true
    $0.contentMode = .fitToBounds
    $0.backdropView.dismissalTapGestureRecognizer.isEnabled = true
    $0.isRemovalInteractionEnabled = true
  }
  
  private let refreshButton = RefreshButton()
  private var refreshButtonCenterYConstraint: Constraint?
  private var isRefreshButtonCentered = true
  
  private let currentLocationButton = UIButton().then {
    $0.setImage(R.image.scope(), for: .normal)
    $0.imageEdgeInsets = UIEdgeInsets(common: 10)
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.addShadow(to: .bottom)
  }
  
  private let showMapButton = CapsuleImageButton(
    imageSize: .init(width: 20, height: 20),
    imagePosition: .left,
    insets: .init(vertical: 10, horizontal: 20)).then {
      $0.title = "지도"
      $0.font = .pretendard(size: 14, weight: .semiBold)
      $0.image = R.image.map()
      $0.spacing = 8
      $0.imageColor = .white
      $0.textColor = .white
      $0.backgroundColor = .init(hex: 0x141C3B)
      $0.addShadow(to: .bottom)
      $0.alpha = 0
  }

  
  // MARK: - Initialization
  
  init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind(viewModel)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateFloatingPanelLayout()
    updateMapViewInset()
  }

  
  // MARK: - Setup
  
  private func setup() {
    setupLayouts()
    setupView()
    setupLocationManager()
  }
  
  private func setupLocationManager() {
    LocationDataManager.shared.didChangeAuthorization
      .sink { [weak self] status in
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
          self?.viewModel.loadMyFinalPosition()
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.loadInitialCakeShops()
          }
        case .denied, .restricted:
          self?.viewModel.setSelectedDistrict()
        default:
          break
        }
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Bind
  
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
      .map { [weak self] in self?.cakkMapView.mapView.contentInset = .zero }
      .compactMap { [weak self] in self?.cakkMapView.mapView.contentBounds }
      .sink { [weak self] bounds in
        self?.viewModel.input.searchByMapBounds.send(bounds)
      }
      .store(in: &cancellableBag)
    
    showMapButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] _ in
        self?.cakeShopListFloatingPanel.move(to: .tip, animated: true)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
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
        guard let self else { return }
        
        if isLoading {
          self.refreshButton.show()
          self.refreshButton.startLoading()
          self.cakeShopListFloatingPanel.move(to: .tip, animated: true)
          self.cakeShopListFloatingPanel.panGestureRecognizer.isEnabled = false
          self.cakeShopDetailFloatingPanel.hide(animated: true)
        } else {
          self.refreshButton.hide()
          self.updateFloatingPanelLayout()
          self.cakeShopListFloatingPanel.panGestureRecognizer.isEnabled = true
        }
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .selectedCakeShop
      .sink { [weak self] cakeShopId in
        guard let self else { return }
        if let cakeShopId {
          self.cakeShopListFloatingPanel.move(to: .tip, animated: true)
          self.showCakeShopDetailFloatingPanel(cakeShopId.id)
        }
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Private methods
  
  private func configureMoveToDetailTapAction(to popupView: CakeShopPopUpView,
                                              with cakeShop: CakeShop) {
    popupView
      .controlEventPublisher(for: .touchUpInside)
      .sink { [weak self] _ in
        let detailController = DIContainer.shared.makeShopDetailViewController(with: cakeShop.id)
        detailController.delegate = self
        self?.navigationController?.pushViewController(detailController, animated: true)
        
      }
      .store(in: &cancellableBag)
  }
  
  private func showChangeDistrictView() {
    let viewController = DIContainer.shared.makeDistrictSelectionController()
    viewController.modalPresentationStyle = .fullScreen
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.present(viewController, animated: true)
    }
  }
  
  private func showFilterFloatingPanel() {
    let viewModel = FilterViewModel()
    let viewController = DIContainer.shared.makeFilterViewController(viewModel: viewModel)
    viewController.applyCompletionHandler = { [weak self] in
      self?.showPistonToast(title: "필터가 적용 되었어요!")
    }
    
    filterFloatingPanel.track(scrollView: viewController.collectionView)
    filterFloatingPanel.addPanel(toParent: self)
    filterFloatingPanel.set(contentViewController: viewController)
    filterFloatingPanel.show()
    filterFloatingPanel.move(to: .tip, animated: true)
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
  
  private func updateMapViewInset() {
    var floatingPanelHeight: CGFloat {
      if cakeShopDetailFloatingPanel.state == .hidden {
        return view.frame.height - abs(cakeShopListFloatingPanel.surfaceView.frame.minY)
      } else {
        return view.frame.height - abs(cakeShopDetailFloatingPanel.surfaceView.frame.minY)
      }
    }
    let leftInset = cakeShopListFloatingPanel.surfaceView.frame.width - view.safeAreaInsets.left
    let cakeShopListFPCState = cakeShopListFloatingPanel.state
    let cakeShopDetailFPCState = cakeShopDetailFloatingPanel.state
    
    if isLandscapeMode {
      if cakeShopListFPCState == .full || cakeShopDetailFPCState == .full || cakeShopDetailFPCState == .half {
        // update camera inset
        cakkMapView.mapView.contentInset = .init(
          top: view.safeAreaInsets.top,
          left: leftInset,
          bottom: 0,
          right: 0)

        // Update refresh button position
        moveRefreshButtonPosition(leftInset: leftInset / 2)
      } else {
        // Update camera inset
        cakkMapView.mapView.contentInset = .zero
        
        // Update refresh button position
        moveRefreshButtonPosition(leftInset: 0)
      }
    } else {
      // update camera inset
      let cakeShopListMinY = cakeShopListFloatingPanel.surfaceView.frame.minY
      let cakeShopDetailMinY = cakeShopDetailFloatingPanel.surfaceView.frame.minY
      let minimumMinYPosition: CGFloat = 200

      // 최대 없데이트 할 수 있는 카메라 inset이 최소 높이 200을 넘지 않도록 하여 constraint 깨지는 문제 방지.
      if cakeShopListMinY > minimumMinYPosition &&
          cakeShopDetailMinY > minimumMinYPosition {
        cakkMapView.mapView.contentInset = .init(
          top: view.safeAreaInsets.top,
          left: 0,
          bottom: floatingPanelHeight - view.safeAreaInsets.bottom,
          right: 0)
        
        // Update refresh button position
        moveRefreshButtonPosition(leftInset: 0)
      }
    }
  }
  
  private func updateFloatingPanelLayout() {
    if isLandscapeMode {
      cakeShopListFloatingPanel.layout = CakeShopListFloatingPanelLandscapeLayout()
      cakeShopDetailFloatingPanel.layout = CakeShopDetailFloatingPanelLandscapeLayout()
    } else {
      cakeShopListFloatingPanel.layout = CakeShopListFloatingPanelLayout()
      cakeShopDetailFloatingPanel.layout = CakeShopDetailFloatingPanelLayout()
    }
    
    cakeShopListFloatingPanel.invalidateLayout()
    cakeShopDetailFloatingPanel.invalidateLayout()
  }
  
  private func showCakeShopDetailFloatingPanel(_ cakeShopId: Int) {
    let viewController = DIContainer.shared.makeShopDetailViewController(with: cakeShopId)
    viewController.delegate = self
    cakeShopDetailFloatingPanel.delegate = self
    cakeShopDetailFloatingPanel.addPanel(toParent: self)
    cakeShopDetailFloatingPanel.set(contentViewController: viewController)
    cakeShopDetailFloatingPanel.track(scrollView: viewController.mainScrollView)
    cakeShopDetailFloatingPanel.move(to: .half, animated: true)
  }
  
  private func moveRefreshButtonPosition(leftInset: CGFloat) {
    if leftInset == .zero {
      if isRefreshButtonCentered == false {
        refreshButtonCenterYConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8,
                       options: [.allowUserInteraction]) {
          self.view.layoutIfNeeded()
        }
        isRefreshButtonCentered = true
      }
    } else {
      if isRefreshButtonCentered == true {
        refreshButtonCenterYConstraint?.update(offset: leftInset)
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8,
                       options: [.allowUserInteraction]) {
          self.view.layoutIfNeeded()
        }
        isRefreshButtonCentered = false
      }
    }
  }
}


// MARK: - UI & Layout

extension MainViewController {
  
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
      refreshButtonCenterYConstraint = $0.centerX.equalToSuperview().constraint
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Metric.verticalPadding)
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
  
  private func setupShowMapButtonLayout() {
    view.addSubview(showMapButton)
    showMapButton.snp.makeConstraints {
      $0.centerX.equalTo(cakeShopListFloatingPanel.surfaceView)
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Metric.showMapButtonBottomInset)
    }
  }
  
  
  // Setup View
  private func setupView() {
    setupBaseView()
    setupCakeShopListFloatingPanel()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .black
    navigationItem.backBarButtonItem = backButtonItem
  }
  
  private func setupCakeShopListFloatingPanel() {
    let viewController = DIContainer.shared.makeCakeShopListViewController(mainViewModel: viewModel)
    viewController.cakeShopItemSelectHandler = { [weak self] cakeShop in
      let coordinate = NMGLatLng(lat: cakeShop.latitude, lng: cakeShop.longitude)
      self?.cakkMapView.moveCamera(coordinate, zoomLevel: nil)
      self?.cakeShopListFloatingPanel.move(to: .half, animated: true)
    }
    viewController.filterButtonTapHandler = { [weak self] in
      self?.showFilterFloatingPanel()
    }
    
    cakeShopListFloatingPanel.set(contentViewController: viewController)
    cakeShopListFloatingPanel.addPanel(toParent: self)
    cakeShopListFloatingPanel.delegate = self
    
    setupShowMapButtonLayout()
  }
}


// MARK: - MapView Extensions

extension MainViewController: NMFMapViewCameraDelegate {

  func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
    if reason == NMFMapChangedByGesture &&
        viewModel.output.loadingCakeShops.value == false &&
        cakeShopListFloatingPanel.contentViewController != nil &&
        isLandscapeMode == false {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        self?.cakeShopListFloatingPanel.move(to: .tip, animated: true)
        
        if self?.cakeShopDetailFloatingPanel.state != .hidden {
          self?.cakeShopDetailFloatingPanel.move(to: .tip, animated: true)
        }
      }
    }
  }
  
  func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
    if viewModel.output.loadingCakeShops.value == false &&
        reason == NMFMapChangedByGesture {
      refreshButton.show()
    }
    
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
  
  func floatingPanelDidMove(_ fpc: FloatingPanelController) {
    updateMapViewInset()
  }

  func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
    if fpc == cakeShopListFloatingPanel {
      // Show and hide cakeShopPopupView
      UIView.animate(withDuration: 0.3) {
        if fpc.state == .full {
          self.showMapButton.alpha = 1
        } else {
          self.showMapButton.alpha = 0
        }
      }
    }
  }
  
  func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
    if fpc == cakeShopDetailFloatingPanel {
      cakeShopListFloatingPanel.move(to: .half, animated: true)
      cakkMapView.unselectMarker()
    }
  }
}


// MARK: - ShopDetailViewControllerDelegate

// 상세화면에서 처리한 북마크 상태를 리스트 뷰컨으로 전달해서 셀에 반영되게 함
extension MainViewController: ShopDetailViewControllerDelegate {
  func shopDetailViewController(_ viewController: ShopDetailViewController,
                                didBookmarkStateChanged isBookmarked: Bool,
                                of cakeShopID: Int) {
    guard let viewController = cakeShopListFloatingPanel
      .contentViewController as? CakeShopListViewController else { return }
    
    viewController.applyBookmarkStateToCell(of: cakeShopID, isBookmarked: isBookmarked)
    
    if isBookmarked {
      showPistonToast(title: "케이크샵을 저장했어요!")
    } else {
      showPistonToast(title: "북마크한 케이크샵에서 삭제되었습니다.")
    }
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ViewControllerPreView: PreviewProvider {
  static var previews: some View {
    let viewModel = MainViewModel(service: .init(type: .stub), storage: MockRealmStorage())
    MainViewController(viewModel: viewModel)
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
