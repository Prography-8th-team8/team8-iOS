//
//  CakeShopTypeChip.swift
//  CAKK
//
//  Created by 이승기 on 2023/05/09.
//

import UIKit

class CakeShopTypeChip: LabelChip {
  
  
  // MARK: - Properties
  
  private var cakeShopType: CakeShopType
  
  
  // MARK: - Initialization
  
  init(_ cakeShopType: CakeShopType) {
    self.cakeShopType = cakeShopType
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
    title = cakeShopType.localizedString
    titleColor = cakeShopType.color
    isBackgroundSynced = true
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct CakeShopTypeChipPreview: PreviewProvider {
  static var previews: some View {
    VStack {
      ForEach(CakeShopType.allCases, id: \.self) { type in
        UIViewPreview {
          let cakeShopTypeChip = CakeShopTypeChip(type)
          return cakeShopTypeChip
        }
      }
    }
  }
}
#endif
