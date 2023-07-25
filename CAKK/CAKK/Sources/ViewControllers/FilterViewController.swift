//
//  FilterViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/06/23.
//

import UIKit

import Combine

import SnapKit
import Then

class FilterViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let topPadding = 22.f
    static let bottomPadding = 12.f
    static let horizontalPadding = 20.f
    
    static let headerFontSize = 18.f
    static let subtitleFontSize = 14.f
    
    static let applyButtonFontSize = 18.f
    static let applyButtonCornerRadius = 15.f
    static let applyButtonHeight = 57.f
    
    static let closeButtonSize = 25.f
    static let closeButtonImageInset = 4.f
    
    static let refreshButtonSize = 24.f
    static let refreshButtonImageInset = 4.f
  }
  
  
  // MARK: - Types
  
  typealias ViewModel = FilterViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, CakeCategory>
  
  enum Section {
    case cakeCategories
  }
  
  
  // MARK: - Properties
  
  private var viewModel: ViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  private lazy var dataSource: DataSource = makeDataSource()
  private var cellRegistration = UICollectionView.CellRegistration<CakeCategoryCell, CakeCategory> { _, _, _ in }
  
  
  // MARK: - UI
  
  private let headerLabel = UILabel().then {
    $0.text = "Filter"
    $0.textColor = R.color.black()
    $0.font = .pretendard(size: Metric.headerFontSize, weight: .bold)
  }
  
  private let subtitleLabel = UILabel().then {
    $0.text = "원하는 디자인의 케이크샵을 추천해 드려요!"
    $0.textColor = R.color.black()!.withAlphaComponent(0.8)
    $0.font = .pretendard(size: Metric.subtitleFontSize)
  }
  
  private let applyButton = UIButton().then {
    $0.layer.cornerRadius = Metric.applyButtonCornerRadius
    $0.setTitle("필터 적용", for: .normal)
    $0.setTitle("필터를 선택해 주세요", for: .disabled)
    $0.setTitleColor(R.color.white(), for: .normal)
    $0.setTitleColor(R.color.white()?.withAlphaComponent(0.3), for: .highlighted)
    $0.titleLabel?.font = .pretendard(size: Metric.applyButtonFontSize, weight: .bold)
    $0.backgroundColor = R.color.pink_100()
  }
  
  public lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: self.collectionViewLayout()).then {
      $0.alwaysBounceVertical = false
      $0.delaysContentTouches = false
    }
  
  private let closeButton = UIButton().then {
    $0.setImage(.init(systemName: "xmark"), for: .normal)
    $0.tintColor = R.color.black()
    $0.imageEdgeInsets = .init(common: Metric.closeButtonImageInset)
  }
  
  private let refreshButton = UIButton().then {
    $0.setImage(R.image.arrow_circlepath(), for: .normal)
    $0.tintColor = R.color.gray_40()
    $0.backgroundColor = R.color.gray_10()
    $0.layer.cornerRadius = Metric.refreshButtonSize / 2
    $0.imageEdgeInsets = .init(common: Metric.refreshButtonImageInset)
  }
  
  
  // MARK: - Initializers
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupLayout()
    setupDataSource()
  }
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    applyButton
      .tapPublisher
      .sink { [weak self] _ in
        self?.viewModel.input.apply.send(Void())
        self?.dismiss(animated: true)
      }
      .store(in: &cancellableBag)
    
    closeButton
      .tapPublisher
      .sink { [weak self] in
        self?.dismiss(animated: true)
      }
      .store(in: &cancellableBag)
    
    refreshButton
      .tapPublisher
      .sink { [weak self] in
        self?.viewModel.input.refresh.send(Void())
        self?.refreshAllCells()
      }
      .store(in: &cancellableBag)
    
    collectionView
      .didSelectItemPublisher
      .sink { [weak self] indexPath in
        guard let self else { return }
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? CakeCategoryCell else { return }
        cell.isChipSelected.toggle()
        self.viewModel.input.selectItem.send(indexPath)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output
      .categoriesChanged
      .sink { [weak self] isChanged in
        guard let self else { return }
        
        if isChanged {
          self.applyButton.isEnabled = true
          self.applyButton.backgroundColor = R.color.pink_100()
        } else {
          self.applyButton.isEnabled = false
          self.applyButton.backgroundColor = R.color.gray_20()
        }
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Private
  
  private func refreshAllCells() {
    collectionView.visibleCells.forEach { cell in
      if let cell = cell as? CakeCategoryCell {
        cell.isChipSelected = false
      }
    }
  }
}


// MARK: - UI & Layouts

extension FilterViewController {
  
  private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .estimated(46),
      heightDimension: .estimated(34))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(34))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    group.interItemSpacing = .fixed(8)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 12
    
    return .init(section: section)
  }
  
  
  // MARK: - Setup Layout
  
  private func setupLayout() {
    setupCloseButtonLayout()
    setupHeaderLabelLayout()
    setupSubtitleLabelLayout()
    setupRefreshButtonLayout()
    setupApplyButtonLayout()
    setupCollectionViewLayout()
  }
  
  private func setupCloseButtonLayout() {
    view.addSubview(closeButton)
    closeButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(Metric.topPadding)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metric.horizontalPadding)
      $0.size.equalTo(Metric.closeButtonSize)
    }
  }
  
  private func setupHeaderLabelLayout() {
    view.addSubview(headerLabel)
    headerLabel.snp.makeConstraints {
      $0.top.equalTo(closeButton.snp.bottom).offset(8)
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupSubtitleLabelLayout() {
    view.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(headerLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupRefreshButtonLayout() {
    view.addSubview(refreshButton)
    refreshButton.snp.makeConstraints {
      $0.centerY.equalTo(subtitleLabel)
      $0.leading.equalTo(subtitleLabel.snp.trailing).offset(8)
      $0.size.equalTo(Metric.refreshButtonSize)
    }
  }
  
  private func setupApplyButtonLayout() {
    view.addSubview(applyButton)
    applyButton.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(Metric.horizontalPadding)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(Metric.bottomPadding)
      $0.height.equalTo(Metric.applyButtonHeight)
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(subtitleLabel.snp.bottom).offset(26)
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
      $0.bottom.equalTo(applyButton.snp.top)
    }
  }
}


// MARK: - DataSource & Snapshot

extension FilterViewController {
  
  private func setupDataSource() {
    let section: [Section] = [.cakeCategories]
    var snapshot = NSDiffableDataSourceSnapshot<Section, CakeCategory>()
    snapshot.appendSections(section)
    snapshot.appendItems(CakeCategory.allCases)
    dataSource.apply(snapshot)
  }
  
  private func makeDataSource() -> DataSource {
    DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, category in
      guard let self else { return UICollectionViewCell() }
      
      let cell = collectionView.dequeueConfiguredReusableCell(
        using: self.cellRegistration,
        for: indexPath,
        item: category)
      let isSelected = viewModel.isSelected(category)
      cell.configure(cakeCategory: category, isSelected: isSelected)
      
      return cell
    }
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct FilterViewController_Preview: PreviewProvider {
  static var previews: some View {
    FilterViewController(viewModel: .init())
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
