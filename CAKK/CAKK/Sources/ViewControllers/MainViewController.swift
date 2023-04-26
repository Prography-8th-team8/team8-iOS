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
  
  enum Constants {
    static let refreshButtonText: String = "새로 고침"
    static let seeLocationButtonText: String = "지도 보기"
  }
  
  enum Metric {
    static let refreshButtonOffset = 16.f
    
    static let naverMapViewHeightRatio = 0.5
    static let naverMapBottomInset = 10.f

    static let seeLocationButtonBottomInset = 28.f
    
    static let bottomSheetTipModeHeight = 58.f
  }

  
  // MARK: - Properties

  private var cancellableBag = Set<AnyCancellable>()

  
  // MARK: - UI
  
  private let naverMapView = NMFNaverMapView(frame: .zero).then {
    $0.showZoomControls = false
  }
  
  private let refreshButton = CapsuleStyleButton(
    iconImage: UIImage(systemName: "arrow.clockwise")!,
    text: Constants.refreshButtonText
  )
  private lazy var seeLocationButton = CapsuleStyleButton(
    iconImage: UIImage(systemName: "map")!,
    text: Constants.seeLocationButtonText
  ).then {
    $0.isHidden = true
    $0.addTarget(self, action: #selector(seeLocation), for: .touchUpInside)
  }

  private let bottomSheetView = BottomSheetView()
  private let cakeListViewController = CakeListViewController()
  
  private var isTableViewPanning: Bool = false

  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }


  // MARK: - Private
  
  private func setup() {
    setupBaseView()
    setupLayouts()
    setupBottomSheet()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .systemBackground
  }

  private func setupBottomSheet() {
    bottomSheetView.layout = BottomSheetLayout(
      half: .fractional(0.5),
      tip: .absolute(
        0
//        CakeListViewController.Metric.headerViewHeight +
//        Metric.bottomSheetTipModeHeight
      )
    )
                                               
    bottomSheetView.configure(
      parentViewController: self,
      contentViewController: cakeListViewController
    )
    bottomSheetView.snp.makeConstraints {
      $0.top.equalTo(naverMapView.snp.bottom)
        .inset(Metric.naverMapBottomInset)
        .priority(.low)
    }
  }
  
  private func setupLayouts() {
    view.addSubview(naverMapView)
    naverMapView.snp.makeConstraints {
      $0.top.left.right.equalToSuperview()
      $0.height.greaterThanOrEqualTo(view.frame.height * Metric.naverMapViewHeightRatio)
        .priority(.required)
    }
    
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Metric.refreshButtonOffset)
      $0.centerX.equalToSuperview()
    }

    view.addSubview(seeLocationButton)
    seeLocationButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(Metric.seeLocationButtonBottomInset)
    }
  }

  @objc private func seeLocation() {
    bottomSheetView.move(to: .half)
  }

}


// MARK: - Preview

import SwiftUI

struct ViewControllerPreView: PreviewProvider {
  static var previews: some View {
    MainViewController().toPreview()
  }
}
