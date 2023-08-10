//
//  UIControlImageView.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/15.
//

import UIKit

import SnapKit
import Then

import Kingfisher

class UIControlImageView: UIControl {
  
  // MARK: - Properties
  
  public let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupLayout()
    setupEvents()
  }
  
  private func setupLayout() {
    addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupEvents() {
    addTarget(self, action: #selector(highlight), for: .touchDown)
    addTarget(self, action: #selector(unhighlight), for: .touchUpInside)
    addTarget(self, action: #selector(unhighlight), for: .touchCancel)
    addTarget(self, action: #selector(unhighlight), for: .touchDragOutside)
  }
  
  
  // MARK: - Public
  
  public func setImage(urlString: String, placeholder: UIImage? = nil) {
    let url = URL(string: urlString)
    imageView.setDownsampledImage(url: url, placeholder: placeholder)
  }
  
  public func setupCornerRadius(_ radius: CGFloat) {
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = radius
  }
  
  
  // MARK: - Private
  
  @objc
  private func highlight() {
    imageView.alpha = 0.4
  }
  
  @objc
  private func unhighlight() {
    imageView.alpha = 1
  }
}
