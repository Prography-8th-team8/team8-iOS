//
//  OnboardingViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/06.
//

import UIKit

import SnapKit
import Then

import Combine

class OnboardingViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Metric {
    static let padding = 16.f
    static let topPadding = 44.f
    
    static let descriptionLabelTopPadding = 12.f
    
    static let collectionViewTopPadding = 40.f
  }
  
  static var layout: UICollectionViewCompositionalLayout {
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
  
  typealias ViewModel = OnboardingViewModel
  typealias DataSource = UICollectionViewDiffableDataSource<Section, DistrictSection>
  
  
  // MARK: - Properties
  
  public var viewModel: ViewModel!
  private var dataSource: DataSource!
  private var cancellableBag = Set<AnyCancellable>()
  
  private var regionPickerCellRegistration = UICollectionView.CellRegistration<RegionPickerCollectionCell, DistrictSection> { cell, _, item in
    cell.configure(item)
  }
  
  enum Section {
    case regionSelector
  }
  
  
  // MARK: - UI
  
  let titleLabel = UILabel().then {
    $0.text = "내게 맞는 케이크샵은 어디에 있을까요?"
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.textColor = .black
    $0.textAlignment = .left
  }
  let descriptionLabel = UILabel().then {
    $0.text = "서울의 케이샵을 지역별로 정리했어요."
    $0.font = .pretendard(size: 16)
    $0.textColor = .black.withAlphaComponent(0.6)
    $0.textAlignment = .left
  }
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: OnboardingViewController.layout).then {
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
    setupCollectionView()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .white
  }
  
  private func setupCollectionView() {
    collectionView.delegate = self
    
    dataSource = DataSource(
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
  
  private func bindInput() { }
  
  private func bindOutput() {
    viewModel.output.districtSections
      .sink { [weak self] districtSections in
        let section: [Section] = [.regionSelector]
        var snapshot = NSDiffableDataSourceSnapshot<Section, DistrictSection>()
        snapshot.appendSections(section)
        snapshot.appendItems(districtSections)
        self?.dataSource.apply(snapshot)
      }
      .store(in: &cancellableBag)
    
    viewModel.output.presentMainView
      .sink { [weak self] _ in
        guard let self else { return }
        let vc = MainViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
      }
      .store(in: &cancellableBag)
  }
}


// MARK: - Extensions

extension OnboardingViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    viewModel.input
      .selectDistrict
      .send(indexPath)
  }
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct OnboardingViewControllerPreview: PreviewProvider {
  static var previews: some View {
    OnboardingViewController(viewModel: .init()).toPreview()
      .ignoresSafeArea()
  }
}
#endif
