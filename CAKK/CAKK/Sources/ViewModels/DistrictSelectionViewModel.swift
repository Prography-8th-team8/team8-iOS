//
//  DistrictSelectionViewModel.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import Foundation

import Combine

final class DistrictSelectionViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let selectDistrict = PassthroughSubject<IndexPath, Never>()
  }
  
  struct Output {
    let districtSections = CurrentValueSubject<[DistrictSection], Never>([])
    let selectedDistrictSection = PassthroughSubject<DistrictSection, Never>()
  }
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  private let service: NetworkService<CakeAPI>
  
  
  // MARK: - Initialization
  
  init(service: NetworkService<CakeAPI>) {
    self.service = service
    
    self.input = Input()
    self.output = Output()
    
    bind(input, output)
    
    setupData()
  }
  
  
  // MARK: - Private
  
  private func bind(_ input: Input, _ output: Output) {
    bindSelectDistrict(input, output)
  }
  
  private func bindSelectDistrict(_ input: Input, _ output: Output) {
    input.selectDistrict
      .sink { indexPath in
        if let selectedDistrictSection = output.districtSections.value[safe: indexPath.row] {
          output.selectedDistrictSection.send(selectedDistrictSection)
        }
        
        if let section = DistrictSection.Section(rawValue: indexPath.row) {
          DistrictUserDefault.shared.updateSelected(districtSection: section)
        }
      }
      .store(in: &cancellableBag)
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
