//
//  ShopDetailViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit
import SafariServices

import SnapKit
import Then

import Combine

final class ShopDetailViewController: UIViewController {
  
  // MARK: - Constants
  
  enum Constants {
    static let skeletonText = "-"
  }
  
  enum Metric {
    static let horizontalPadding = 14.f
  }
  
  enum Section {
    case blogPost
  }
  
  typealias BlogPostDataSource = UICollectionViewDiffableDataSource<Section, BlogPost>
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private var cancellableBag = Set<AnyCancellable>()
  
  private lazy var blogPostDataSource = makeBlogPostDataSource()
  
  // MARK: - UI
  
  private let mainScrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .always
  }
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let shopImageView = UIImageView().then {
    $0.image = R.image.noimage()
    $0.backgroundColor = R.color.stroke()
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .pretendard(size: 20, weight: .bold)
    $0.text = Constants.skeletonText
    $0.textAlignment = .center
  }
  
  // 주소
  private let addressLabel = UILabel().then {
    $0.font = .pretendard(size: 16)
    $0.text = Constants.skeletonText
    $0.textAlignment = .center
    // 텍스트가 길면 사이즈가 줄어들 수 있게함
    $0.adjustsFontSizeToFitWidth = true
    $0.minimumScaleFactor = 0.7
    $0.lineBreakMode = .byTruncatingTail
    $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // 줄어들게 하기 위해 우선순위 낮춤
  }
  
  private var dotLabel: UILabel {
    return UILabel().then {
      $0.textColor = R.color.stroke()
      $0.text = "·"
    }
  }
  
  private let copyAddressButton = UIButton().then {
    $0.setAttributedTitle(
      NSAttributedString(
        string: "주소 복사",
        attributes: [.font: UIFont.pretendard(weight: .bold)]), for: .normal
    )
  }
  
  private lazy var addressStackView = UIStackView(arrangedSubviews: [
    addressLabel,
    dotLabel,
    copyAddressButton
  ]).then {
    $0.alignment = .center
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private let addressContainerView = UIView()
  
  // 메뉴 버튼
  private let callMenuButton = DetailMenuButton(image: R.image.call(), title: "전화하기")
  private let bookmarkMenuButton = DetailMenuButton(image: R.image.bookmark(), title: "북마크")
  private let naviMenuButton = DetailMenuButton(image: R.image.navi(), title: "길 안내")
  private let shareMenuButton = DetailMenuButton(image: R.image.share(), title: "공유하기")
  
  private lazy var menuButtonStackView = UIStackView(
    arrangedSubviews: [callMenuButton,
                       //                       naviMenuButton,
                       shareMenuButton]
  ).then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.addSeparators(color: R.color.stroke()?.withAlphaComponent(0.5))
  }
  
  private lazy var headerStackView = UIStackView(
    arrangedSubviews: [nameLabel,
                       addressContainerView,
                       menuButtonStackView]
  ).then {
    $0.axis = .vertical
    $0.spacing = 12
    $0.setCustomSpacing(32, after: addressContainerView)
  }
  
  // 키워드
  private let keywordTitleView = DetailSectionTitleView(title: "키워드")
  
  private let keywordScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }
  private let keywordContentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private var separatorView: UIView {
    UIView().then {
      $0.snp.makeConstraints { view in
        view.height.equalTo(10)
      }
      $0.backgroundColor = R.color.stroke()?.withAlphaComponent(0.2)
    }
  }
  
  private let detailInfoView = DetailInfoView()
  
  private let blogReviewTitleView = DetailSectionTitleView(title: "블로그 리뷰")
  
  private lazy var blogPostCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: blogPostCollectionViewLayout).then {
      $0.registerCell(cellClass: BlogPostCell.self)
      $0.addBorder(to: .bottom, color: R.color.gray_5())
  }
  private lazy var blogPostCollectionViewLayout = UICollectionViewFlowLayout().then {
    $0.minimumLineSpacing = 0
    $0.itemSize = CGSize(width: view.bounds.width - (Metric.horizontalPadding * 2), height: 150)
  }
  // 블로그 포스팅 컬렉션뷰의 사이즈가 내부 컨텐츠의 사이즈와 동일하게 하기 위한 constraints
  private var blogPostCollectionViewHeightConstraint: Constraint?
  
  private let loadMoreBlogPostsButton = UIButton().then {
    $0.titleLabel?.font = .pretendard(size: 14, weight: .bold)
    $0.layer.borderColor = R.color.gray_5()?.cgColor
    $0.layer.borderWidth = 2
    $0.layer.cornerRadius = 8
    $0.setTitle("블로그 리뷰 더 보기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
  }
  
  private lazy var indicatorContainerView = UIView(frame: view.bounds).then {
    $0.backgroundColor = .systemBackground
  }
  
  private lazy var indicatorView = UIActivityIndicatorView().then {
    $0.center = indicatorContainerView.center
    $0.color = .gray
    $0.style = .medium
  }
  
  // MARK: - LifeCycle
  
  init(viewModel: ShopDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupScrollViewLayout()
    setupShopImageViewLayout()
    setupHeaderStackViewLayout()
    setupKeywordTitleLabelLayout()
    setupKeywordScrollViewLayout()
    
    // TODO: - 일단 영업시간.. 같은 상세정보가 없으니 가림.
    //    setupDetailInfoViewLayout()
    
    setupBlogReviewViewLayout()
    setupActivityIndicator()
  }
  
  private func setupScrollViewLayout() {
    view.addSubview(mainScrollView)
    mainScrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    mainScrollView.addSubview(contentStackView)
    contentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
  }
  
  private func setupShopImageViewLayout() {
    contentStackView.addArrangedSubview(shopImageView)
    shopImageView.snp.makeConstraints {
      $0.height.equalTo(view.frame.width * 0.5)
    }
    contentStackView.setCustomSpacing(48, after: shopImageView)
  }
  
  private func setupHeaderStackViewLayout() {
    contentStackView.addArrangedSubview(headerStackView)
    contentStackView.setCustomSpacing(38, after: headerStackView)
    addSeperatorLineView()
    
    // 스택뷰 내부의 주소 부분을 중간으로 잡기 위한 containerView 구성
    addressContainerView.addSubview(addressStackView)
    addressStackView.snp.makeConstraints {
      $0.verticalEdges.equalToSuperview()
      // 중간 지점에 오면서, 동시에 안쪽으로 패딩을 주기 위함
      $0.centerX.equalToSuperview()
      $0.leading.greaterThanOrEqualToSuperview().inset(Metric.horizontalPadding)
      $0.trailing.lessThanOrEqualToSuperview().inset(Metric.horizontalPadding)
    }
  }
  
  private func setupKeywordTitleLabelLayout() {
    contentStackView.addArrangedSubview(keywordTitleView)
  }
  
  private func setupKeywordScrollViewLayout() {
    contentStackView.addArrangedSubview(keywordScrollView)
    keywordScrollView.addSubview(keywordContentStackView)
    keywordContentStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalToSuperview()
    }
    contentStackView.setCustomSpacing(20, after: keywordScrollView)
  }
  
  private func setupDetailInfoViewLayout() {
    contentStackView.addArrangedSubview(separatorView)
    contentStackView.addArrangedSubview(detailInfoView)
  }
  
  private func setupBlogReviewViewLayout() {
    contentStackView.addArrangedSubview(separatorView)
    contentStackView.addArrangedSubview(blogReviewTitleView)
    contentStackView.addArrangedSubview(blogPostCollectionView)
    
    blogPostCollectionView.snp.makeConstraints {
      blogPostCollectionViewHeightConstraint = $0.height.equalTo(0).constraint
    }
    
    contentStackView.addArrangedSubview(loadMoreBlogPostsButton)
    loadMoreBlogPostsButton.snp.makeConstraints {
      $0.height.equalTo(48)
    }
  }
  
  private func addSeperatorLineView(withBottomSpacing spacing: CGFloat = 0) {
    let seperatorView = UIView().then {
      $0.backgroundColor = R.color.stroke()?.withAlphaComponent(0.5)
      $0.snp.makeConstraints { view in
        view.height.equalTo(1)
      }
    }
    contentStackView.addArrangedSubview(seperatorView)
    contentStackView.setCustomSpacing(spacing, after: seperatorView)
  }
  
  private func setupActivityIndicator() {
    view.addSubview(indicatorContainerView)
    indicatorContainerView.addSubview(indicatorView)
    setActivityIndicator(toAnimate: true)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.setActivityIndicator(toAnimate: false)
    }
  }
  
  private func setupView() {
    view.backgroundColor = .white
    title = "상세정보"
  }
  
  private func setupCakeShopTypeChips(with cakeShopDetail: CakeShopDetailResponse) {
    let chipViews = cakeShopDetail.cakeShopTypes.map {
      CakeShopTypeChip($0)
    }
    
    chipViews.forEach {
      keywordContentStackView.addArrangedSubview($0)
    }
  }
  
  private func makeBlogPostDataSource() -> BlogPostDataSource {
    return BlogPostDataSource(
      collectionView: blogPostCollectionView,
      cellProvider: { collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(cellClass: BlogPostCell.self,
                                                      for: indexPath)
        cell.configure(with: item)
        return cell
      })
  }
  
  private func setActivityIndicator(toAnimate isAnimate: Bool) {
    guard isAnimate != indicatorView.isAnimating else { return }
    
    let alpha: CGFloat = isAnimate ? 1.0 : 0.0
    UIView.animate(withDuration: 0.5) {
      self.indicatorContainerView.alpha = alpha
    }
    
    if isAnimate {
      indicatorView.startAnimating()
    } else {
      indicatorView.stopAnimating()
    }
  }
  
  private func applySnapshot(with blogPosts: [BlogPost]) {
    let section: [Section] = [.blogPost]
    var snapshot = NSDiffableDataSourceSnapshot<Section, BlogPost>()
    snapshot.appendSections(section)
    snapshot.appendItems(blogPosts)
    
    blogPostDataSource.apply(snapshot) { [weak self] in
      self?.updateBlogPostCollectionViewHeight()
    }
  }
 
  // 컬렉션뷰의 내부의 컨텐츠 사이즈와 동일하게 해줌 (스크롤이 안되는, 전체를 감싸는 스택뷰처럼 처리함)
  private func updateBlogPostCollectionViewHeight() {
    blogPostCollectionViewHeightConstraint?.update(
      offset: blogPostCollectionView.contentSize.height)
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    viewModel.input.viewDidLoad.send()
    
    loadMoreBlogPostsButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        guard let self else { return }
        self.viewModel.input.loadMoreBlogPosts.send()
      }
      .store(in: &cancellableBag)
    
    // 각 블로그 포스트 셀을 눌렀을 때, 사파리 컨트롤러로 포스팅 링크를 띄워줌
    blogPostCollectionView.didSelectItemPublisher
      .sink { [weak self] indexPath in
        guard let blogPost = self?.blogPostDataSource.itemIdentifier(for: indexPath),
              let url = URL(string: blogPost.link) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        self?.present(safariViewController, animated: true)
      }
      .store(in: &cancellableBag)
    
    // 클립보드에 복사
    copyAddressButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak addressLabel] in
        UIPasteboard.general.string = addressLabel?.text ?? ""
      }
      .store(in: &cancellableBag)
  }
  
  private func bindOutput() {
    viewModel.output.cakeShopDetail
      .sink { [weak self] cakeShopDetail in
        guard let self else { return }
        
        self.nameLabel.text = cakeShopDetail.name
        self.addressLabel.text = cakeShopDetail.address
        self.setupCakeShopTypeChips(with: cakeShopDetail)
        self.setActivityIndicator(toAnimate: false)
      }
      .store(in: &cancellableBag)
    
    viewModel.output.failToFetchDetail
      .sink { [weak self] in
        guard let self else { return }
        self.showFailAlert(with: "상세 정보를 불러오지 못했어요.") {
          self.navigationController?.popViewController(animated: true)
        }
      }
      .store(in: &cancellableBag)
    
    viewModel.output.blogPostsToShow
      .sink { [weak self] blogPosts in
        self?.applySnapshot(with: blogPosts)
      }
      .store(in: &cancellableBag)
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ShopDetailViewControllerPreView: PreviewProvider {
  static var previews: some View {
    UINavigationController(
      rootViewController:
        ShopDetailViewController(
          viewModel: ShopDetailViewModel(
            cakeShop: SampleData.cakeShopList.first!,
            service: NetworkService<CakeAPI>(type: .stub)))
    ).toPreview()
  }
}
#endif
