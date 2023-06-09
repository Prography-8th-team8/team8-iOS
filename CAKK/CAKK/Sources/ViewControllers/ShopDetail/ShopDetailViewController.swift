//
//  ShopDetailViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

import Combine

import SnapKit
import Then

import SafariServices


final class ShopDetailViewController: UIViewController {
  
  
  // MARK: - Constants
  
  enum Constants {
    static let skeletonText = "-"
  }
  
  enum Metric {
    static let horizontalPadding = 14.f
  }
  
  
  // MARK: - Properties
  
  private let viewModel: ShopDetailViewModel
  
  private var cancellables = Set<AnyCancellable>()
  
  private var selectedPage: Int = 0 {
    didSet {
      let direction: UIPageViewController.NavigationDirection = oldValue <= selectedPage ? .forward : .reverse
      guard let destination = contentViewControllers[safe: selectedPage] else { return }
      pageViewController.setViewControllers([destination], direction: direction, animated: true)
    }
  }
  
  
  // MARK: - UI
  
  public let mainScrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .always
  }
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let shopImageView = UIImageView().then {
    $0.image = R.image.noimage()
    $0.backgroundColor = R.color.stroke()
    $0.contentMode = .scaleAspectFill
    $0.snp.makeConstraints { make in
      make.width.height.equalTo(72)
    }
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 36
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .pretendard(size: 18, weight: .bold)
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
  
  private lazy var nameAddressStackView = UIStackView(
    arrangedSubviews: [nameLabel, addressLabel]
  ).then {
    $0.alignment = .leading
    $0.axis = .vertical
    $0.spacing = 12
  }
  
  private lazy var infoStackView = UIStackView(
    arrangedSubviews: [shopImageView, nameAddressStackView]
  ).then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.alignment = .center
    $0.spacing = 16
  }
  
  private let infoStackContainerView = UIView()
  
  // 메뉴 버튼
  private let linkMenuButton = DetailMenuButton(image: R.image.instagram(), title: "전화하기")
  private let bookmarkMenuButton = DetailMenuButton(image: R.image.bookmark(), title: "북마크")
  private let routeMenuButton = DetailMenuButton(image: R.image.pin_map(), title: "길 안내")
  private let shareMenuButton = DetailMenuButton(image: R.image.arrow_up_square(), title: "공유하기")
  
  private lazy var menuButtonStackView = UIStackView(
    arrangedSubviews: [linkMenuButton,
                       bookmarkMenuButton,
                       routeMenuButton,
                       shareMenuButton]
  ).then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.addSeparators(color: R.color.stroke()?.withAlphaComponent(0.5))
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
  
  
  // 케이크 이미지 뷰컨트롤러
  private lazy var cakeImagesViewController = CakeImagesViewController(
    viewModel: viewModel,
    collectionViewLayout: UICollectionViewFlowLayout())
  
  // 블로그 포스트 뷰컨트롤러
  private lazy var blogPostsViewController = BlogPostsViewController(
    viewModel: viewModel,
    collectionViewLayout: UICollectionViewFlowLayout())
  
  lazy var contentViewControllers: [UIViewController] = [cakeImagesViewController, blogPostsViewController]
  
  // 케이크 이미지, 블로그 리뷰 전환 세그먼티드 컨트롤
  private let segmentedControl = UnderlineSegmentedControl(items: ["케이크 이미지", "블로그 리뷰"]).then {
    $0.addBorder(to: .top, color: R.color.gray_5())
    $0.addBorder(to: .bottom, color: R.color.gray_20())
  }
  
  // 케이크 이미지, 블로그 리뷰 페이징을 위한 컨트롤러
  private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal).then {
    $0.setViewControllers([cakeImagesViewController], direction: .forward, animated: true)
    $0.delegate = self
    $0.dataSource = self
  }
  

  private lazy var indicatorContainerView = UIView(frame: view.bounds).then {
    $0.backgroundColor = .systemBackground
  }
  
  private lazy var indicatorView = UIActivityIndicatorView().then {
    $0.center = indicatorContainerView.center
    $0.color = .gray
    $0.style = .medium
  }
  
  
  // MARK: - Initialization
  
  init(viewModel: ShopDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  
  // MARK: - Private
  
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
  
  private func showBlogPostSafariController(of indexPath: IndexPath) {
    guard let blogPost = blogPostsViewController.blogPost(of: indexPath),
          let url = URL(string: blogPost.link) else { return }
    
    let safariViewController = SFSafariViewController(url: url)
    present(safariViewController, animated: true)
  }
  
  private func showLinkSafariController(link: String) {
    guard let url = URL(string: link) else { return }
    let safariViewController = SFSafariViewController(url: url)
    present(safariViewController, animated: true)
  }
  
  private func makePhoneCall() {
    guard let phoneNumber = viewModel.output.cakeShopDetail.value?.phoneNumber,
          phoneNumber.isEmpty == false,
          let phoneNumberURL = URL(string: "tel://\(phoneNumber)") else { return }
    
    UIApplication.shared.open(phoneNumberURL)
  }
  
  // MARK: - Bind
  
  private func bind() {
    bindInput()
    bindOutput()
  }
  
  private func bindInput() {
    viewModel.input.viewDidLoad.send()
    
    bindBlogPostCollectionView()
    bindLinkMenuButton()
    bindRouteMenuButton()
    bindBookmarkMenuButton()
    bindShareMenuButton()
    bindSegmentedControl()
  }
  
  private func bindOutput() {
    bindCakeShopDetail()
    bindFailToFetchDetail()
    bindIsBookmarked()
  }
  
  private func bindBlogPostCollectionView() {
    // 각 블로그 포스트 셀을 눌렀을 때, 사파리 컨트롤러로 포스팅 링크를 띄워줌
    blogPostsViewController.collectionView.didSelectItemPublisher
      .sink { [weak self] indexPath in
        self?.showBlogPostSafariController(of: indexPath)
      }
      .store(in: &cancellables)
  }
  
  private func bindLinkMenuButton() {
    linkMenuButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        guard let self = self,
              let link = self.viewModel.output.cakeShopDetail.value?.link else { return }
        self.showLinkSafariController(link: link)
      }
      .store(in: &cancellables)
  }
  
  private func bindRouteMenuButton() {
    routeMenuButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        self?.showRouteActionSheet()
      }
      .store(in: &cancellables)
  }
  
  private func bindBookmarkMenuButton() {
    bookmarkMenuButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .sink { [weak self] in
        self?.viewModel.input.tapBookmarkButton.send()
      }
      .store(in: &cancellables)
  }
  
  private func bindShareMenuButton() {
    shareMenuButton.tapPublisher
      .throttle(for: 1, scheduler: DispatchQueue.main, latest: false)
      .compactMap { [weak self] in
        self?.viewModel.output.cakeShopDetail.value
      }
      .sink { [weak self] cakeShopDetail in
        guard let self = self else { return }
        let items = [cakeShopDetail.name,
                     cakeShopDetail.address,
                     cakeShopDetail.link]
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.modalPresentationStyle = .popover
        activityController.popoverPresentationController?.sourceView = shareMenuButton // 아이패드를 위한 설정
        self.present(activityController, animated: true)
      }
      .store(in: &cancellables)
  }
  
  private func bindSegmentedControl() {
    segmentedControl.selectedSegmentIndexPublisher
      .sink { [weak self] index in
        self?.selectedPage = index
      }
      .store(in: &cancellables)
  }
  
  private func bindCakeShopDetail() {
    viewModel.output.cakeShopDetail
      .sink { [weak self] cakeShopDetail in
        guard let self,
              let cakeShopDetail else { return }
        
        self.nameLabel.text = cakeShopDetail.name
        self.addressLabel.text = cakeShopDetail.address
        self.setupCakeCategoryChips(with: cakeShopDetail)
        self.setActivityIndicator(toAnimate: false)
        self.configureLinkMenuButton(with: cakeShopDetail)
        
        if let thumbnailURL = URL(string: cakeShopDetail.thumbnail) {
          self.shopImageView.kf.setImage(with: thumbnailURL)
        }
      }
      .store(in: &cancellables)
  }
  
  private func bindFailToFetchDetail() {
    viewModel.output.failToFetchDetail
      .sink { [weak self] in
        guard let self else { return }
        self.showFailAlert(with: "상세 정보를 불러오지 못했어요.") {
          self.navigationController?.popViewController(animated: true)
        }
      }
      .store(in: &cancellables)
  }
  
  private func bindIsBookmarked() {
    viewModel.output.isBookmarked
      .sink { [weak self] isBookmarked in
        let buttonImage = isBookmarked ? R.image.bookmark_filled() : R.image.bookmark()
        self?.bookmarkMenuButton.update(image: buttonImage)
      }
      .store(in: &cancellables)
  }
}


// MARK: - UI & Layout

extension ShopDetailViewController {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupScrollViewLayout()
    setupInfoStackViewLayout()
    setupMenuStackViewLayout()
    setupKeywordTitleLabelLayout()
    setupKeywordScrollViewLayout()
    setupSegmentedControlLayout()
    setupPageViewControllerLayout()
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
  
  private func setupInfoStackViewLayout() {
    infoStackContainerView.addSubview(infoStackView)
    infoStackView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }
    
    contentStackView.addArrangedSubview(infoStackContainerView)
  }
  
  private func setupMenuStackViewLayout() {
    contentStackView.addArrangedSubview(menuButtonStackView)
    
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
  
  private func setupSegmentedControlLayout() {
    contentStackView.addArrangedSubview(segmentedControl)
    segmentedControl.snp.makeConstraints {
      $0.height.equalTo(50)
    }
  }
  
  private func setupPageViewControllerLayout() {
    view.addSubview(pageViewController.view)
    addChild(pageViewController)
    
    pageViewController.view.snp.makeConstraints {
      $0.top.equalTo(segmentedControl.snp.bottom)
      $0.horizontalEdges.bottom.equalToSuperview()
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
  
  private func setupCakeCategoryChips(with cakeShopDetail: CakeShopDetailResponse) {
    var chipViews = cakeShopDetail.cakeCategories.map {
      CakeCategoryChipView($0)
    }
    
    if cakeShopDetail.cakeCategories.isEmpty {
      chipViews = [CakeCategoryChipView(emptyKeyword: true)]
    }
    
    chipViews.forEach {
      keywordContentStackView.addArrangedSubview($0)
    }
  }
  
  private func configureLinkMenuButton(with cakeShopDetail: CakeShopDetailResponse) {
    if cakeShopDetail.link.contains("instagram") {
      linkMenuButton.menuImageView.image = R.image.instagram()
      linkMenuButton.menuTitleLabel.text = "인스타그램"
      return
    }
    
    if cakeShopDetail.link.contains("pf.kakao") {
      linkMenuButton.menuImageView.image = R.image.kakao()
      linkMenuButton.menuTitleLabel.text = "카카오톡"
      return
    }
    
    linkMenuButton.menuImageView.image = R.image.website()
    linkMenuButton.menuTitleLabel.text = "웹사이트"
  }
  
  private func showRouteActionSheet() {
    let alertController = UIAlertController(title: "길안내", message: nil, preferredStyle: .actionSheet)
    let copyAddressAction = UIAlertAction(title: "주소 복사", style: .default) { [weak self] _ in
      UIPasteboard.general.string = self?.addressLabel.text ?? ""
      self?.showToast(with: "주소가 클립보드에 복사되었습니다.")
    }
    alertController.addAction(copyAddressAction)
    
    let naverMapRouteAction = UIAlertAction(title: "네이버 지도 앱에서 보기", style: .default) { [weak self] _ in
      self?.openNaverMapRoute()
    }
    alertController.addAction(naverMapRouteAction)
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    alertController.addAction(cancelAction)
    
    // 아이패드에선 화면 중앙에 나타나도록 설정
    if let popoverController = alertController.popoverPresentationController {
      popoverController.sourceView = view // 액션시트가 표시될 기준 뷰
      popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
      popoverController.permittedArrowDirections = [] // 화살표 표시 없음
    }
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func openNaverMapRoute() {
    guard let naverMapRouteURL = viewModel.output.naverMapRouteURL.value else { return }
    
    guard UIApplication.shared.canOpenURL(naverMapRouteURL) else {
      if let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8") {
        UIApplication.shared.open(appStoreURL)
      }
      return
    }
    
    UIApplication.shared.open(naverMapRouteURL)
  }
}


// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource

extension ShopDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let index = contentViewControllers.firstIndex(of: viewController) else { return nil }
    let previousIndex = index - 1
    guard previousIndex >= 0,
          let destination = contentViewControllers[safe: previousIndex] else { return nil }
    
    return destination
  }
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let index = contentViewControllers.firstIndex(of: viewController) else { return nil }
    let nextIndex = index + 1
    guard nextIndex < contentViewControllers.count,
          let destination = contentViewControllers[safe: nextIndex] else { return nil }
    
    return destination
  }
  
  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    guard completed,
          let currentViewController = pageViewController.viewControllers?.first,
          let index = contentViewControllers.firstIndex(of: currentViewController) else {
      return
    }
    segmentedControl.selectedSegmentIndex = index
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
            service: NetworkService<CakeAPI>(type: .stub),
            realmStorage: RealmStorage()))
    ).toPreview()
  }
}
#endif
