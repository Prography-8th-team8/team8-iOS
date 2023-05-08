//
//  OnboardingViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit
import Combine

class OnboardingViewModel: ObservableObject {
  
  // MARK: - Types
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, DistrictSection>
  
  
  // MARK: - Properties
  
  struct Input { }
  struct Output { }
  
  public var input: Input!
  public var output: Output!
  
  public var dataSource: DataSource! {
    didSet {
      setupDataSource()
    }
  }
  public enum Section {
    case region
  }
  
  
  // MARK: - LifeCycles
  
  init() {
    setupInputOutput()
  }
  
  
  // MARK: - Private
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    self.input = input
    self.output = output
  }
  
  public func setupDataSource() {
    let section: [Section] = [.region]
    var snapshot = NSDiffableDataSourceSnapshot<Section, DistrictSection>()
    snapshot.appendSections(section)
    snapshot.appendItems(DistrictSection.items())
    dataSource.apply(snapshot)
  }
}
