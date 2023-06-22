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
    let selectDistrict = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    let districtSections = CurrentValueSubject<[DistrictSection], Never>([])
    let selectedDistrictSection = PassthroughSubject<DistrictSection, Never>()
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private var cancellableBag = Set<AnyCancellable>()
  
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - LifeCycles
  
  init(service: NetworkService<CakeAPI>) {
    self.service = service
    setupInputOutput()
    setupData()
  }
  
  
  // MARK: - Private
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    input.selectDistrict
      .sink { indexPath in
        if let selectedDistrictSection = output.districtSections.value[safe: indexPath.row] {
          output.selectedDistrictSection.send(selectedDistrictSection)
        }
        
        if let section = DistrictSection.Section(rawValue: indexPath.row) {
          DistrictUserDefaults.shared.updateSelected(districtSection: section)
        }
      }
      .store(in: &cancellableBag)
    
    self.input = input
    self.output = output
  }
  
  private func setupData() {
    loadDistricts()
  }
  
  private func loadDistricts() {
    service
      .request(.fetchDistrictCounts, type: DistrictCountResponse.self)
      .receive(on: DispatchQueue.main)
      .map { districtCountResponse in
        return DistrictSection.convert(from: districtCountResponse)
      }
      .sink { completion in
        switch completion {
        case .finished:
          break
        case .failure(let error):
          print(error)
        }
      } receiveValue: { [weak self] districtSections in
        self?.output.districtSections
          .send(districtSections)
      }
      .store(in: &cancellableBag)
  }
}
