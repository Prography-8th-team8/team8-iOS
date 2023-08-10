//
//  LoadMoreBlogPostFooterView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/07.
//

import UIKit

import SnapKit
import Then


final class LoadMoreBlogPostFooterView: UICollectionReusableView {
  let button = UIButton().then {
    $0.titleLabel?.font = .pretendard(size: 14, weight: .bold)
    $0.layer.borderColor = R.color.gray_5()?.cgColor
    $0.layer.borderWidth = 2
    $0.layer.cornerRadius = 8
    $0.setTitle("블로그 리뷰 더 보기", for: .normal)
    $0.setTitleColor(.black, for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(button)
    button.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(14)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview().inset(BlogPostsViewController.Metric.loadMoreBlogPostButtonBottomPadding)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
