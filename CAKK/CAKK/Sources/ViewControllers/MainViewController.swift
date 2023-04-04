//
//  MainViewController.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit
import SnapKit
import Then

import NMapsMap

final class MainViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let refreshButtonOffset = 16.f
    
    static let cakelistTableViewHeight = (140 + 16).f
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
      (1.0 - self.ratio) * UIScreen.main.bounds.height
    }
  }
  
  // MARK: - Properties
  
  var bottomSheetMode: BottonSheetMode = .middle {
    didSet {
      updateBottonSheetConstraint(withOffset: bottomSheetMode.yPosition)
    }
  }
  
  // MARK: - UI
  
  private let naverMapView = NMFNaverMapView(frame: .zero)
  
  private let refreshButton = RefreshButton()
  
  private let bottomSheetView = BottonSheetView()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      self.bottomSheetMode = .full
//    }
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupBaseView()
    setupLayouts()
    setupTableView()
    
    setupGesture()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
  }
  
  private func setupLayouts() {
    view.addSubview(naverMapView)
    naverMapView.snp.makeConstraints {
      $0.top.left.right.equalToSuperview()
      $0.height.equalTo(view.frame.height * 0.6)
    }
    
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Metric.refreshButtonOffset)
      $0.centerX.equalToSuperview()
    }
    
    view.addSubview(bottomSheetView)
    bottomSheetView.snp.makeConstraints {
      $0.left.right.bottom.equalToSuperview()
//      $0.left.right.equalToSuperview()
//      $0.bottom.equalToSuperview().offset(200)
      $0.top.equalToSuperview().offset(bottomSheetMode.yPosition)
    }
  }
  
  private func setupTableView() {
    bottomSheetView.cakeTableView.dataSource = self
    bottomSheetView.cakeTableView.delegate = self
  }
  
  private func setupGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
    bottomSheetView.addGestureRecognizer(panGesture)
  }
  
  @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
    let translationY = recognizer.translation(in: bottomSheetView).y
    let minY = bottomSheetView.frame.minY
    let offset = translationY + minY
    
    if isValid(yPosition: offset) {
      updateBottonSheetConstraint(withOffset: offset)
      recognizer.setTranslation(.zero, in: bottomSheetView)
    }
    
    UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut,
                   animations: bottomSheetView.layoutIfNeeded)
    
    didEndPan(recognizer)
  }
  
  private func isValid(yPosition: Double) -> Bool {
    (BottonSheetMode.full.yPosition...BottonSheetMode.middle.yPosition).contains(yPosition)
  }
  
  private func didEndPan(_ recognizer: UIPanGestureRecognizer) {
    guard recognizer.state == .ended else { return }
    let isDownDirection = recognizer.velocity(in: self.bottomSheetView).y >= 0
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction,
                   animations: { [weak self] in
      guard let self else { return }
      self.bottomSheetMode = isDownDirection ? BottonSheetMode.middle : .full
      self.bottomSheetView.layoutIfNeeded()
    })
  }
  
  private func updateBottonSheetConstraint(withOffset offset: Double) {
    bottomSheetView.snp.remakeConstraints {
      $0.left.right.bottom.equalToSuperview()
      $0.top.equalToSuperview().offset(offset)
    }
//      bottomSheetView.snp.updateConstraints {
//        $0.top.equalToSuperview().offset(offset)
//      }
  }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(cellClass: CakeListCell.self, for: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Metric.cakelistTableViewHeight
  }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
}
