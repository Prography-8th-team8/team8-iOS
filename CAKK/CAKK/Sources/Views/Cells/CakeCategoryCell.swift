//
//  CakeCategoryCell.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/23.
//

import UIKit
import Combine

import SnapKit
import Then

class CakeCategoryCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  enum Metric {
    static let chipHeight = 40.f
    static let chipHorizontalTitlePadding = 12.f
    static let chipVerticalTitlePadding = 8.f
    static let titleFontSize = 14.f
  }
  
  // MARK: - Types
  
  typealias ViewModel = FilterViewModel
  
  
  // MARK: - Properties
  
  private weak var viewModel: ViewModel?
  private var cancellableBag = Set<AnyCancellable>()
  
  public var cakeCategory: CakeCategory?
  public var isChipSelected: Bool = false {
    didSet {
      if isChipSelected {
        setSelected()
      } else {
        setUnselected()
      }
    }
  }
  
  
  // MARK: - UI
  
  private let chipButton = UIButton().then {
    $0.titleLabel?.font = .pretendard(size: Metric.titleFontSize, weight: .bold)
    $0.setTitleColor(R.color.black(), for: .normal)
    $0.contentEdgeInsets = .init(
      top: Metric.chipVerticalTitlePadding,
      left: Metric.chipHorizontalTitlePadding,
      bottom: Metric.chipVerticalTitlePadding,
      right: Metric.chipHorizontalTitlePadding)
    $0.layer.cornerRadius = Metric.chipHeight / 2
    $0.layer.borderWidth = 1
    $0.layer.borderColor = R.color.gray_20()!.cgColor
    $0.isHidden = true
  }
  
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setup
  
  private func setup() {
    setupView()
  }
  
  private func setupView() {
    setupChipButton()
  }
  
  private func setupChipButton() {
    contentView.addSubview(chipButton)
    chipButton.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(Metric.chipHeight)
    }
  }
  
  
  // MARK: - Public
  
  public func configure(viewModel: ViewModel?, cakeCategory: CakeCategory) {
    self.viewModel = viewModel
    self.cakeCategory = cakeCategory
    
    chipButton.isHidden = false
    chipButton.setTitle(cakeCategory.localizedString, for: .normal)
    
    if viewModel!.output.categories.value.contains(cakeCategory) {
      isChipSelected = true
    } else {
      isChipSelected = false
    }
  }
  
  
  // MARK: - Private
  
  private func bind() {
    chipButton
      .tapPublisher
      .sink { [weak self] _ in
        guard let self,
              let cakeCategory = self.cakeCategory else { return }
        
        if self.isChipSelected {
          viewModel?.input
            .removeCategory
            .send(cakeCategory)
        } else {
          viewModel?.input
            .addCategory
            .send(cakeCategory)
        }
        
        isChipSelected.toggle()
      }
      .store(in: &cancellableBag)
  }
  
  private func setSelected() {
    if let cakeCategory {
      chipButton.setTitleColor(cakeCategory.color, for: .normal)
      chipButton.setTitleColor(cakeCategory.color.withAlphaComponent(0.3), for: .highlighted)
      chipButton.backgroundColor = cakeCategory.color.withAlphaComponent(0.2)
      chipButton.layer.borderWidth = 0
    }
  }
  
  private func setUnselected() {
    chipButton.setTitleColor(R.color.black(), for: .normal)
    chipButton.setTitleColor(R.color.gray_20(), for: .highlighted)
    chipButton.backgroundColor = .white
    chipButton.layer.borderWidth = 1
    chipButton.layer.borderColor = R.color.gray_20()!.cgColor
  }
}
