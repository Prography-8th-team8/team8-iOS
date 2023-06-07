//
//  DistrictSelectionViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

import Combine

class DistrictSelectionViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let padding = 16.f
    static let topPadding = 44.f
    
    static let descriptionLabelTopPadding = 12.f
    
    static let collectionViewTopPadding = 40.f
  }
  
  private var collectionViewLayout: UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.5),
      heightDimension: .estimated(120))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 2)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(120))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 4
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  
  // MARK: - Types
  
  typealias ViewModel = DistrictSelectionViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, DistrictSection>
  
  
  // MARK: - Properties
  
  private let viewModel: ViewModel
  private lazy var dataSource: DataSource = makeDataSource()
  private var cancellableBag = Set<AnyCancellable>()
  
  private let regionPickerCellRegistration = UICollectionView.CellRegistration<RegionPickerCollectionCell, DistrictSection> { cell, _, item in
    cell.configure(item)
  }
  
  enum Section {
    case regionSelector
  }
  
  
  // MARK: - UI
  
  private let titleLabel = UILabel().then {
    $0.text = "내게 맞는 케이크샵은 어디에 있을까요?"
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .left
  }
  private let descriptionLabel = UILabel().then {
    $0.text = "서울의 케이샵을 지역별로 정리했어요."
    $0.font = .pretendard(size: 16)
    $0.textColor = .black.withAlphaComponent(0.6)
    $0.textAlignment = .left
  }
  private lazy var collectionView = UICollectionView(frame: .zero,
                                                     collectionViewLayout: collectionViewLayout).then {
    $0.delaysContentTouches = false
    $0.register(RegionPickerCollectionCell.self, forCellWithReuseIdentifier: RegionPickerCollectionCell.identifier)
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = false
  }
  
  
  // MARK: - LifeCycle
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: - Public
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
    bind()
  }
  
  // Setup Layouts
  private func setupLayout() {
    setupTitleLabelLayout()
    setupDescriptionLabelLayout()
    setupCollectionViewLayout()
  }
  
  private func setupTitleLabelLayout() {
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.layoutMarginsGuide.snp.top).inset(Metric.topPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupDescriptionLabelLayout() {
    view.addSubview(descriptionLabel)
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(Metric.descriptionLabelTopPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupCollectionViewLayout() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(Metric.collectionViewTopPadding)
      $0.leading.trailing.equalToSuperview().inset(Metric.padding)
      $0.bottom.equalToSuperview()
    }
  }
  
  // Setup Views
  private func setupView() {
    setupBaseView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
  
  private func makeDataSource() -> DataSource {
    return DataSource(
      collectionView: collectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueConfiguredReusableCell(
          using: self.regionPickerCellRegistration,
          for: indexPath,
          item: item)
        cell.configure(item)
        return cell
      })
  }
  
  // Bind
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    collectionView.didSelectItemPublisher
      .sink { [weak self] indexPath in
        guard let self = self else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.viewModel.input
          .selectDistrict
          .send(indexPath)
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output.districtSections
      .sink { [weak self] districtSections in
        self?.applySnapshot(with: districtSections)
      }
      .store(in: &cancellableBag)
    
    viewModel.output.selectedDistrictSection
      .sink { [weak self] _ in
        self?.dismiss(animated: true)
      }
      .store(in: &cancellableBag)
  }
  
  private func applySnapshot(with districtSections: [DistrictSection]) {
    let section: [Section] = [.regionSelector]
    var snapshot = NSDiffableDataSourceSnapshot<Section, DistrictSection>()
    snapshot.appendSections(section)
    snapshot.appendItems(districtSections)
    dataSource.apply(snapshot)
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct OnboardingViewControllerPreview: PreviewProvider {
  static var previews: some View {
    DistrictSelectionViewController(viewModel: .init()).toPreview()
      .ignoresSafeArea()
  }
}
#endif
