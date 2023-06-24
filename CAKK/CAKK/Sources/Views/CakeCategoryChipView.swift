//
//  CakeCategoryChipView.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/09.
//

import UIKit

class CakeCategoryChipView: LabelChip {
  
  
  // MARK: - Properties
  
  private var cakeCategory: CakeCategory
  
  
  // MARK: - Initialization
  
  init(_ cakeCategory: CakeCategory) {
    self.cakeCategory = cakeCategory
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Private
  
  private func setup() {
    setupView()
  }
  
  private func setupView() {
    setupChipView()
  }
  
  private func setupChipView() {
    title = cakeCategory.localizedString
    titleColor = cakeCategory.color
    isBackgroundSynced = true
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeCategoryChipPreview: PreviewProvider {
  static var previews: some View {
    VStack {
      ForEach(CakeCategory.allCases, id: \.self) { type in
        UIViewPreview {
          let cakeCategoryChip = CakeCategoryChipView(type)
          return cakeCategoryChip
        }
      }
    }
  }
}
#endif
