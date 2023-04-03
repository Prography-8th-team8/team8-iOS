//
//  MainViewController.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit
import SnapKit
import NMapsMap
import Then

final class MainViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric { }
  
  // MARK: - Properties
  
  // MARK: - UI
  
  private let naverMapView = NMFNaverMapView(frame: .zero)
  
  private let refreshButton = RefreshButton()
  
  private let bottomSheetView = BottonSheetView()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupBaseView()
    setupLayouts()
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
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
      $0.centerX.equalToSuperview()
    }
    
    view.addSubview(bottomSheetView)
    bottomSheetView.snp.makeConstraints {
      $0.left.right.bottom.equalToSuperview()
      $0.height.equalTo(view.frame.height * 0.5)
    }
  }
}
