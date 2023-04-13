//
//  MainViewController.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit
import Combine

import SnapKit
import Then

import NMapsMap

final class MainViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let refreshButtonOffset = 16.f
    
    static let cakelistTableViewHeight = (140 + 16).f
    static let naverMapViewHeightRatio = 0.65

    static let seeLocationButtonBottomInset = 28.f
  }
  
  enum BottonSheetMode {
    case middle
    case full
    
    var ratio: Double {
      switch self {
      case .middle:
        return 0.5
      case .full:
        return 1.0
      }
    }
    var yPosition: Double {
      (1.0 - self.ratio) * UIScreen.main.bounds.height + SafeAreaGuide.top
    }
  }
  
  // MARK: - Properties
  
  @Published var bottomSheetMode: BottonSheetMode = .middle

  private var cancellableBag = Set<AnyCancellable>()
  
  // MARK: - UI
  
  private let naverMapView = NMFNaverMapView(frame: .zero).then {
    $0.showZoomControls = false
  }
  
  private let refreshButton = CapsuleStyleButton(iconImage: UIImage(systemName: "arrow.clockwise")!, text: "새로 고침")
  private lazy var seeLocationButton = CapsuleStyleButton(iconImage: UIImage(systemName: "map")!, text: "지도 보기").then {
    $0.isHidden = true
    $0.addTarget(self, action: #selector(seeLocation), for: .touchUpInside)
  }
  
  private let bottomSheetView = BottonSheetView()
  
  private var isTableViewPanning: Bool = false
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupBaseView()
    setupLayouts()
    setupTableView()
    
    setupGestures()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
  }
  
  private func setupLayouts() {
    view.addSubview(naverMapView)
    naverMapView.snp.makeConstraints {
      $0.top.left.right.equalToSuperview()
      $0.height.equalTo(view.frame.height * Metric.naverMapViewHeightRatio)
    }
    
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Metric.refreshButtonOffset)
      $0.centerX.equalToSuperview()
    }
    
    view.addSubview(bottomSheetView)
    bottomSheetView.snp.makeConstraints {
      $0.left.right.bottom.equalToSuperview()
      $0.top.equalToSuperview().offset(bottomSheetMode.yPosition)
    }

    view.addSubview(seeLocationButton)
    seeLocationButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(Metric.seeLocationButtonBottomInset)
    }
  }
  
  private func setupTableView() {
    bottomSheetView.cakeTableView.dataSource = self
    bottomSheetView.cakeTableView.delegate = self
  }

  // MARK: - Bind

  private func bind() {
    bindBottomSheetMode()
  }
  
  // MARK: - Bottom Sheet Animation
  
  private func setupGestures() {
    let headerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(headerDidPan))
    bottomSheetView.addGestureRecognizer(headerPanGesture)
    
    bottomSheetView.cakeTableView.panGestureRecognizer.addTarget(
      self, 
      action: #selector(tableViewDidPan)
    )
  }
  
  @objc private func headerDidPan(_ recognizer: UIPanGestureRecognizer) {
    didPan(recognizer, standardView: bottomSheetView)
    
    if recognizer.state == .ended {
      didEndPan(recognizer, standardView: bottomSheetView.cakeTableView)
    }
  }
  
  @objc private func tableViewDidPan(_ recognizer: UIPanGestureRecognizer) {
    guard (bottomSheetMode == .full && bottomSheetView.cakeTableView.contentOffset.y == 0)
            || isTableViewPanning else {
      return
    }
    
    isTableViewPanning = true
    bottomSheetView.cakeTableView.contentOffset.y = 0
    
    didPan(recognizer, standardView: bottomSheetView.cakeTableView)
    
    if recognizer.state == .ended {
      didEndPan(recognizer, standardView: bottomSheetView.cakeTableView) 
      isTableViewPanning = false
    }
  }

  private func didPan(_ recognizer: UIPanGestureRecognizer, standardView: UIView) {
    let translationY = recognizer.translation(in: standardView).y
    let bottomSheetMinY = bottomSheetView.frame.minY
    let offset = translationY + bottomSheetMinY
    
    guard isValidToPan(yPosition: offset) else { return }
    updateBottonSheetConstraint(withOffset: offset)
    recognizer.setTranslation(.zero, in: bottomSheetView)
    
    UIView.animate(withDuration: 0, delay: 0, options: .allowUserInteraction,
                   animations: bottomSheetView.layoutIfNeeded)
  }
  
  private func isValidToPan(yPosition: Double) -> Bool {
    (BottonSheetMode.full.yPosition...BottonSheetMode.middle.yPosition).contains(yPosition)
  }
  
  private func didEndPan(_ recognizer: UIPanGestureRecognizer, standardView: UIView) {
    let isDownDirection = recognizer.velocity(in: standardView).y >= 0
    bottomSheetMode = isDownDirection ? .middle : .full
    
    UIView.animateWithDamping { [weak self] in
      self?.view.layoutIfNeeded()
    }
  }
  
  private func updateBottonSheetConstraint(withOffset offset: Double) {
    bottomSheetView.snp.updateConstraints {
      $0.top.equalToSuperview().offset(offset)
    }
  }

  func bindBottomSheetMode() {
    $bottomSheetMode
      .sink { [weak self] bottomSheetMode in
        guard let self else { return }
        self.updateBottonSheetConstraint(withOffset: bottomSheetMode.yPosition)
        self.updateSeeLocationHiddenState(with: bottomSheetMode)
        self.bottomSheetView.cakeTableView.isScrollEnabled = bottomSheetMode == .full
        if bottomSheetMode == .middle {
          self.bottomSheetView.cakeTableView.scrollToTop()
        }
      }
      .store(in: &cancellableBag)
  }

  private func updateSeeLocationHiddenState(with bottomSheetMode: BottonSheetMode) {
    switch bottomSheetMode {
    case .full:
      seeLocationButton.fadeIn()
    case .middle:
      seeLocationButton.fadeOut()
    }
  }

  @objc private func seeLocation() {
    bottomSheetMode = .middle
    UIView.animateWithDamping { [weak self] in
      self?.view.layoutIfNeeded()
    }
  }

}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(cellClass: CakeListCell.self, for: indexPath)

    // 첫번째 셀의 top padding 만 좀 더 크게 해주기 위한 logic
    if indexPath == IndexPath(row: 0, section: 0) {
      cell.configreFirstCellTopPadding()
    }

    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Metric.cakelistTableViewHeight
  }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
}
