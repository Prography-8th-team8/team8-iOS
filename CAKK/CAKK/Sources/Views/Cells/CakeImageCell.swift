//
//  CakeImageCell.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/04.
//

import UIKit

import SnapKit
import Then

import Kingfisher


final class CakeImageCell: UICollectionViewCell {
  
  
  // MARK: - UI
  
  let imageView = UIImageView().then {
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
  }
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Public
  
  public func configure(imageURL: String) {
    guard let url = URL(string: imageURL) else { return }
    imageView.setDownsampledImage(with: url)
  }
  
  
  // MARK: - Private
  
  private func setup() {
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
