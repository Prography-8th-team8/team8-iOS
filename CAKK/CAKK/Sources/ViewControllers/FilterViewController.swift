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
    static let topPadding = 28.f
    static let horizontalPadding = 20.f
    
    static let headerFontSize = 18.f
    static let subtitleFontSize = 14.f
    
    static let applyButtonHeight = 72.f
    static let applyButtonFontSize = 18.f
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
    $0.text = "카테고리와 맞는 디자인의 케이크 샵을 추천해 드려요!"
    $0.textColor = R.color.black()!.withAlphaComponent(0.8)
    $0.font = .pretendard(size: Metric.subtitleFontSize)
  }
  
  private let applyButton = UIButton().then {
    $0.setTitle("필터 적용", for: .normal)
    $0.setTitle("필터를 선택해 주세요", for: .disabled)
    $0.setTitleColor(R.color.white(), for: .normal)
    $0.setTitleColor(R.color.white()?.withAlphaComponent(0.3), for: .highlighted)
    $0.titleLabel?.font = .pretendard(size: Metric.applyButtonFontSize, weight: .bold)
    $0.backgroundColor = R.color.black()
  }
  
  public lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: self.collectionViewLayout()).then {
      $0.alwaysBounceVertical = false
      $0.delaysContentTouches = false
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
    setupView()
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
  }
  
  private func bindOutput() {
    viewModel.output
      .categoriesChanged
      .sink { [weak self] isChanged in
        guard let self else { return }
        
        if isChanged {
          self.applyButton.isEnabled = true
          self.applyButton.backgroundColor = R.color.black()
        } else {
          self.applyButton.isEnabled = false
          self.applyButton.backgroundColor = R.color.gray_20()
        }
      }
      .store(in: &cancellableBag)
  }
}



// MARK: - UI & Layouts
extension FilterViewController {
  
  private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .estimated(46),
      heightDimension: .estimated(30))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(30))
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item])
    group.interItemSpacing = .fixed(8)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 12
    
    return .init(section: section)
  }
  
  // MARK: - Configure Layout
  
  override func viewSafeAreaInsetsDidChange() {
    configureApplyButtonLayout()
  }
  
  private func configureApplyButtonLayout() {
    applyButton.snp.makeConstraints {
      $0.height.equalTo(Metric.applyButtonHeight + view.safeAreaInsets.bottom)
    }
    applyButton.titleEdgeInsets.bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
  }
  
  
  // MARK: - Setup Layout
  
  private func setupLayout() {
    setupHeaderLabelLayout()
    setupSubtitleLabelLayout()
    setupApplyButtonLayout()
    setupCollectionViewLayout()
  }
  
  private func setupHeaderLabelLayout() {
    view.addSubview(headerLabel)
    headerLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Metric.topPadding)
      $0.leading.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupSubtitleLabelLayout() {
    view.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(headerLabel.snp.bottom).offset(12)
      $0.leading.trailing.equalToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupApplyButtonLayout() {
    view.addSubview(applyButton)
    applyButton.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
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

  
  // MARK: - Setup View
  
  private func setupView() {
    let section: [Section] = [.cakeCategories]
    var snapshot = NSDiffableDataSourceSnapshot<Section, CakeCategory>()
    snapshot.appendSections(section)
    snapshot.appendItems(CakeCategory.allCases)
    dataSource.apply(snapshot)
  }
}


// MARK: - DataSource & Snapshot

extension FilterViewController {
  
  private func makeDataSource() -> DataSource {
    DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, shopType in
      guard let self else { return UICollectionViewCell() }
      
      let cell = collectionView.dequeueConfiguredReusableCell(
        using: self.cellRegistration,
        for: indexPath,
        item: shopType)
      cell.configure(viewModel: self.viewModel, cakeCategory: shopType)
      
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
