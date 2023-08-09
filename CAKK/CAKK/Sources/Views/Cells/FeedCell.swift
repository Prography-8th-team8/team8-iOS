//
//  FeedCell.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/30.
//

import UIKit

import SnapKit
import Then
import Kingfisher

final class FeedCell: UICollectionViewCell {
  
  // MARK: - Constants
  
  static let id = String(describing: FeedCell.self)
  
  // MARK: - UI
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.backgroundColor = R.color.gray_10()
    $0.clipsToBounds = true
  }
  
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func configure(feed: Feed) {
    configureImage(feed.imageUrl)
  }
  
  private func configureImage(_ imageUrl: String) {
    let url = URL(string: imageUrl)
    imageView.kf.setImage(with: url)
  }
}


// MARK: - UI & Layout

extension FeedCell {
  
  private func setup() {
    setupLayout()
  }
  
  private func setupLayout() {
    setupImageViewLayout()
  }
  
  private func setupImageViewLayout() {
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
