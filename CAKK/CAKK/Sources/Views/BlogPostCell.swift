//
//  BlogPostView.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/11.
//

import UIKit

final class BlogPostCell: HighlightableCell {
  
  
  // MARK: - UI
  
  private let stackView = UIStackView().then {
    $0.alignment = .fill
    $0.distribution = .equalSpacing
    $0.axis = .vertical
  }
  
  private lazy var bloggerNamePostDateLabel = UILabel().then {
    $0.textColor = R.color.black()
    $0.textAlignment = .left
  }
  
  private lazy var titleLabel = UILabel().then {
    $0.font = .pretendard(size: 14, weight: .bold)
    $0.textColor = R.color.black()
    $0.textAlignment = .left
  }
  
  private lazy var contentLabel = UILabel().then {
    $0.numberOfLines = 3
    $0.font = .pretendard()
    $0.textColor = R.color.gray_80()
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
  
  func configure(with blogPost: BlogPost) {
    let blogPost = blogPost.removingHTMLTags()
    
    titleLabel.text = blogPost.title
    contentLabel.text = blogPost.description
    setupBloggerNamePostDateLabelText(of: blogPost)
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    setupStackViewLayout()
    
    stackView.addArrangedSubview(bloggerNamePostDateLabel)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(contentLabel)
  }
  
  private func setupStackViewLayout() {
    contentView.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.verticalEdges.equalToSuperview().inset(24)
      $0.horizontalEdges.equalToSuperview()
    }
  }
  
  private func setupBloggerNamePostDateLabelText(of blogPost: BlogPost) {
    let bloggerNameAttrString = NSAttributedString(
      string: blogPost.bloggerName,
      attributes: [.font: UIFont.pretendard(size: 12, weight: .bold)])
    
    let separatorAttrString = NSAttributedString(
      string: " ・ ",
      attributes: [.font: UIFont.pretendard(size: 12, weight: .bold),
                   .foregroundColor: R.color.gray_20() ?? .gray])
    
    let formattedPostDate = changingPostDateFormat(blogPost.postDate)
    let postDateAttrString = NSAttributedString(
      string: formattedPostDate,
      attributes: [.font: UIFont.pretendard(size: 12),
                   .foregroundColor: R.color.gray_60() ?? .gray])
    
    bloggerNamePostDateLabel.attributedText = NSMutableAttributedString().then { string in
      string.append(bloggerNameAttrString)
      string.append(separatorAttrString)
      string.append(postDateAttrString)
    }
  }
  
  private func changingPostDateFormat(_ postDate: String) -> String {
    guard postDate.count == 8 else { return postDate }
    
    let year = postDate.prefix(4)
    let month = postDate.dropFirst(4).prefix(2)
    let day = postDate.suffix(2)
    return "\(year).\(month).\(day)"
  }
  
  private func setupView() {
    addBorder(to: .top, color: R.color.gray_5())
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct BlogPostCell_Previews: PreviewProvider {
  static var previews: some View {
    UIViewPreview {
      let cell = BlogPostCell()
      cell.configure(with: SampleData.blogPosts.blogPosts[1])
      return cell
    }
    .frame(height: 150)
  }
}
#endif
