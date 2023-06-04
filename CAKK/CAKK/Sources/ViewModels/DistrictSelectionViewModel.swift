//
//  DistrictSelectionViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit
import Combine

class DistrictSelectionViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    var selectDistrict = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    var districtSections = CurrentValueSubject<[DistrictSection], Never>([])
    var selectedDistrictSection = PassthroughSubject<DistrictSection, Never>()
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
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
        let selectedDistrictSection = output.districtSections.value[indexPath.row]
        output.selectedDistrictSection.send(selectedDistrictSection)
        
        if let section = DistrictSection.section(rawValue: indexPath.row) {
          DistrictUserDefaults.shared.updateSelected(districtSection: section)
        }
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
      .send(DistrictSection.section.allCases.map { $0.value() })
  }
}
