//
//  MainViewController.swift
//  CAKK
//
//  Created by CAKK on 2023/03/25.
//

import UIKit

final class MainViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric { }
  
  // MARK: - Properties
  
  // MARK: - UI
  
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
  
  private func setupLayouts() { }
}
