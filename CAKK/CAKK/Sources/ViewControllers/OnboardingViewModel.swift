//
//  OnboardingViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit
import Combine

class OnboardingViewModel {
  
  // MARK: - Properties
  
  struct Input {
    var selectDistrict = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    var districtSections = CurrentValueSubject<[DistrictSection], Never>([])
    var presentMainView = PassthroughSubject<DistrictSection, Never>()
  }
  
  public var input: Input!
  public var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  
  
  // MARK: - LifeCycles
  
  init() {
    setupInputOutput()
    setupData()
  }
  
  
  // MARK: - Private
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    input.selectDistrict
      .sink { indexPath in
        let districtSection = output.districtSections.value[indexPath.row]
        output.presentMainView.send(districtSection)
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
  
  private func setupData() {
    fetchDistrictSections()
  }
  
  private func fetchDistrictSections() {
    output.districtSections
      .send(DistrictSection.items())
  }
}
