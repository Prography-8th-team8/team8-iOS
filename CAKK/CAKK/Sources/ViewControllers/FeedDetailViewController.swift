//
//  FeedDetailViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/02.
//

import UIKit

import Then
import SnapKit

import Combine
import CombineCocoa

import Hero

final class FeedDetailViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constant {
    static let heroDuration = 0.25.f
  }
  
  enum Metric {
    static let padding = 16.f
    
    static let closeButtonSize = 22.f
    static let navigationViewHeight = 52.f
    
    static let toolBarHeight = 104.f
    static let toolBarBottomPadding = 12.f
    
    static let visitCakeShopButtonRadius = 12.f
    static let visitCakeShopButtonHeight = 56.f
    
    static let heartButtonCornerRadius = 12.f
    static let heartButtonSize = 56.f
    
    static let pagingButtonSize = 38.f
  }
  
  
  // MARK: - Types
  
  typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
  
  enum Section {
    case cakeImage
  }
  
  
  // MARK: - Properties
  
  private let viewModel: FeedDetailViewModel
  private var cancellableBag = Set<AnyCancellable>()
  
  private lazy var dataSource: DataSource = makeDataSource()
  private var imageViewerCellRegistration = UICollectionView.CellRegistration<ImageViewerCollectionCell, String> { _, _, _ in }
  
  
  // MARK: - UI
  
  private var oldFrame: CGRect = .zero
  
  private let blurView = UIVisualEffectView().then { view in
    let blurEffect = UIBlurEffect(style: .light)
    view.effect = blurEffect
  }
  
  private let navigationView = UIView().then {
    $0.backgroundColor = .white
    $0.addBorder(to: .bottom, color: R.color.gray_5())
  }
  private let storeNameLabel = UILabel().then {
    $0.font = .pretendard(size: 18, weight: .semiBold)
    $0.textColor = R.color.black()
  }
  private let closeButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = R.color.black()
  }
  private var navigationViewHeightConstraint: Constraint?
  private var storeNameLabelCenterYConstraint: Constraint?
  private var closeButtonCenterYConstraint: Constraint?
  
  private let toolBar = UIView()
  private let visitShopButton = UIButton().then {
    $0.setTitle("케이크샵 방문", for: .normal)
    $0.titleLabel?.font = .pretendard(size: 18, weight: .bold)
    $0.backgroundColor = R.color.pink_100()
    $0.setTitleColor(R.color.white(), for: .normal)
    $0.setTitleColor(R.color.white()?.withAlphaComponent(0.2), for: .highlighted)
    $0.layer.cornerRadius = Metric.visitCakeShopButtonRadius
  }
  private let heartButton = UIButton().then {
    $0.backgroundColor = .white
    $0.setImage(R.image.heart(), for: .normal)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = R.color.gray_10()!.cgColor
    $0.layer.cornerRadius = Metric.heartButtonCornerRadius
    $0.imageEdgeInsets = .init(common: 14)
    $0.tintColor = R.color.gray_40()
  }
  private var toolBarHeightConstraint: Constraint?
  private var visitShopButtonBottomConstraint: Constraint?
  private var heartButtonBottomConstraint: Constraint?
  
  private let nextImageButton = UIButton().then {
    $0.isHidden = true
    $0.setImage(R.image.chevron_right(), for: .normal)
    $0.tintColor = R.color.gray_60()
    $0.backgroundColor = .white.withAlphaComponent(0.8)
    $0.imageEdgeInsets = .init(top: 7, left: 8, bottom: 7, right: 6)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = R.color.gray_10()!.cgColor
    $0.layer.cornerRadius = Metric.pagingButtonSize / 2
  }
  private let previousImageButton = UIButton().then {
    $0.isHidden = true
    $0.setImage(R.image.chevron_left(), for: .normal)
    $0.tintColor = R.color.gray_60()
    $0.backgroundColor = .white.withAlphaComponent(0.8)
    $0.imageEdgeInsets = .init(top: 7, left: 6, bottom: 7, right: 8)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = R.color.gray_10()!.cgColor
    $0.layer.cornerRadius = Metric.pagingButtonSize / 2
  }
  
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = false
  }
  private var collectionViewLayout: UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .paging
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  
  // MARK: - Initializers
  
  init(viewModel: FeedDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    
    setup()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if oldFrame != view.frame {
      configureToolBarGradient()
      oldFrame = view.frame
    }
  }
  
  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    configureLayout()
  }
  
  
  // MARK: - Bindings
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    closeButton
      .tapPublisher
      .sink { [weak self] _ in
        self?.dismiss(animated: true)
      }
      .store(in: &cancellableBag)
    
    visitShopButton
      .tapPublisher
      .sink { [weak self] _ in
        self?.viewModel.input.tapVisitCakeShopButton.send(Void())
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output
      .storeName
      .sink { [weak self] storeName in
        self?.storeNameLabel.text = storeName
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .imageUrls
      .sink { [weak self] imageUrls in
        self?.applySnapshot(with: imageUrls)
      }
      .store(in: &cancellableBag)
    
    viewModel.output
      .isCakeShopDetailShown
      .sink { [weak self] cakeShopId in
        self?.showCakeShopDetail(cakeShopId)
      }
      .store(in: &cancellableBag)
  }
  
  
  // MARK: - Private
  
  private func showCakeShopDetail(_ id: Int) {
    let vc = DIContainer.shared.makeShopDetailViewController(with: id)
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
}


// MARK: - UI & Layout

extension FeedDetailViewController {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  // Setup layout
  private func setupLayout() {
    setupBlurViewLayout()
    setupNavigationViewLayout()
    setupToolBarLayout()
    setupCollectionViewLayout()
    setupPagingButtonLayout()
  }
  
  private func setupBlurViewLayout() {
    view.addSubview(blurView)
    blurView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupNavigationViewLayout() {
    view.addSubview(navigationView)
    navigationView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      navigationViewHeightConstraint = $0.height.equalTo(Metric.navigationViewHeight).constraint
    }
    
    navigationView.addSubview(storeNameLabel)
    storeNameLabel.snp.makeConstraints {
      storeNameLabelCenterYConstraint = $0.centerY.equalToSuperview().constraint
      $0.centerX.equalToSuperview()
    }
    
    navigationView.addSubview(closeButton)
    closeButton.snp.makeConstraints {
      closeButtonCenterYConstraint = $0.centerY.equalToSuperview().constraint
      $0.trailing.equalToSuperview().inset(Metric.padding)
    }
  }
  
  private func setupToolBarLayout() {
    view.addSubview(toolBar)
    toolBar.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(Metric.toolBarHeight)
    }
    
    toolBar.addSubview(heartButton)
    heartButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(Metric.padding)
      $0.size.equalTo(Metric.heartButtonSize)
      visitShopButtonBottomConstraint = $0.bottom.equalToSuperview().inset(Metric.toolBarBottomPadding).constraint
    }
    
    toolBar.addSubview(visitShopButton)
    visitShopButton.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(Metric.padding)
      heartButtonBottomConstraint = $0.bottom.equalToSuperview().inset(Metric.toolBarBottomPadding).constraint
      $0.trailing.equalTo(heartButton.snp.leading).inset(-8)
      $0.height.equalTo(Metric.visitCakeShopButtonHeight)
    }
  }
  
  private func setupCollectionViewLayout() {
    view.insertSubview(collectionView, belowSubview: navigationView)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(navigationView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(toolBar.snp.top).inset(32)
    }
  }
  
  private func setupPagingButtonLayout() {
    view.addSubview(nextImageButton)
    nextImageButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(Metric.padding)
      $0.size.equalTo(Metric.pagingButtonSize)
    }
    
    view.addSubview(previousImageButton)
    previousImageButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(Metric.padding)
      $0.size.equalTo(Metric.pagingButtonSize)
    }
  }
  
  // Configure layout
  private func configureLayout() {
    configureNavigationLayout()
    configureToolBarLayout()
  }
  
  private func configureNavigationLayout() {
    navigationView.snp.remakeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(Metric.navigationViewHeight + view.safeAreaInsets.top)
    }
    closeButtonCenterYConstraint?.update(offset: view.safeAreaInsets.top / 2)
    storeNameLabelCenterYConstraint?.update(offset: view.safeAreaInsets.top / 2)
  }
  
  private func configureToolBarLayout() {
    toolBar.snp.remakeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(Metric.toolBarHeight + view.safeAreaInsets.bottom)
    }
    heartButtonBottomConstraint?.update(inset: Metric.toolBarBottomPadding + view.safeAreaInsets.bottom)
    visitShopButtonBottomConstraint?.update(inset: Metric.toolBarBottomPadding + view.safeAreaInsets.bottom)
  }
  
  
  // Setup view
  private func setupView() {
    setupBaseView()
    setupHero()
  }
  
  private func setupBaseView() {
    view.backgroundColor = .clear
    isHeroEnabled = true
  }
  
  private func setupHero() {
    blurView.heroModifiers = [.fade, .duration(Constant.heroDuration)]
    
    navigationView.isHeroEnabled = true
    navigationView.heroModifiers = [.translate(x: 0, y: -120, z: 0), .duration(Constant.heroDuration), .fade]
    
    toolBar.isHeroEnabled = true
    toolBar.heroModifiers = [.translate(x: 0, y: 160, z: 0), .duration(Constant.heroDuration), .fade]
    
    collectionView.isHeroEnabled = true
    collectionView.heroModifiers = [.scale(0.7), .duration(Constant.heroDuration), .fade]
  }
  
  // Configure view
  private func configureToolBarGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      UIColor.white.withAlphaComponent(0).cgColor,
      UIColor.white.cgColor,
      UIColor.white.cgColor,
      UIColor.white.cgColor
    ]
    gradientLayer.locations = [0.0, 0.25, 1.0]
    gradientLayer.frame = toolBar.bounds
    toolBar.layer.insertSublayer(gradientLayer, at: 0)
  }
}


// MARK: - DataSource & Snapshot

extension FeedDetailViewController {
  
  private func makeDataSource() -> DataSource {
    DataSource(
      collectionView: collectionView) { [weak self] collectionView, indexPath, item in
        guard let self else { return UICollectionViewCell() }
        
        let cell = collectionView.dequeueConfiguredReusableCell(
          using: self.imageViewerCellRegistration,
          for: indexPath,
          item: item)
        cell.configure(imageUrl: item)
        return cell
      }
  }
  
  private func applySnapshot(with imageUrls: [String]) {
    let section: [Section] = [.cakeImage]
    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    snapshot.appendSections(section)
    snapshot.appendItems(imageUrls)
    dataSource.apply(snapshot)
  }
}


// MARK: - Preview

#if DEBUG && canImport(SwiftUI)
import SwiftUI

struct FeedDetailViewController_Preview: PreviewProvider {
  static var previews: some View {
    let feed = Feed(storeId: 308,
                    storeName: "플레플레",
                    district: .mapo,
                    imageUrl: "https://bucket-8th-team8.s3.ap-northeast-2.amazonaws.com/cakk/store/e267878d-f913-4dbe-b178-c83ddda225cd.jpeg")
    DIContainer.shared.makeFeedDetailViewController(feed: feed)
      .toPreview()
      .ignoresSafeArea()
  }
}
#endif
