//
//  DetailMenuButton.swift
//  CAKK
//
//  Created by Mason Kim on 2023/05/10.
//

import UIKit

import SnapKit
import Then

final class DetailMenuButton: UIButton {
  
  // MARK: - UI
  
  let menuTitleLabel = UILabel().then {
    $0.font = .pretendard()
    $0.isUserInteractionEnabled = false
  }
  let menuImageView = UIImageView().then {
    $0.isUserInteractionEnabled = false
    $0.contentMode = .scaleAspectFit
  }
  
  private lazy var stackView = UIStackView(
    arrangedSubviews: [menuImageView, menuTitleLabel]
  ).then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 8
  }
  
  // MARK: - LifeCycle
  
  init(image: UIImage?, title: String) {
    super.init(frame: .zero)
    setup(image: image, title: title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public
  
  func update(image: UIImage?) {
    menuImageView.image = image
  }
  
  func update(title: String) {
    menuTitleLabel.text = title
  }
  
  // MARK: - Private
  
  private func setup(image: UIImage?, title: String) {
    menuTitleLabel.text = title
    menuImageView.image = image
    
    addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct MenuDetailButtonPreview: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let image = UIImage(systemName: "phone")?.withTintColor(.black)
      return DetailMenuButton(image: image, title: "전화하기")
    }
    .padding()
    .frame(width: 120, height: 90)
    .border(.black)
    .previewLayout(.sizeThatFits)
  }
}
#endif
