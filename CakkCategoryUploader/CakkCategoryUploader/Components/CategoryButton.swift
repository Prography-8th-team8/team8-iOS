//
//  CategoryButton.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import SwiftUI

struct CategoryButton: View {
  
  // MARK: - Properties
  
  @EnvironmentObject var store: PostingViewStore
  
  var category: CakeCategory
  @State var isSelected: Bool
  
  
  // MARK: - Views
  
  var body: some View {
    Button {
      if isSelected {
        store.remove(category)
      } else {
        store.add(category)
      }
      
      isSelected.toggle()
    } label: {
      Text(category.localizedString)
        .font(.system(size: 13, weight: .bold))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundColor(isSelected ? .white : .black)
        .background(isSelected ? Color.black : Color.white)
        .clipShape(Capsule())
        .overlay(
          Capsule()
            .stroke(isSelected ? .clear : Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
  }
}


// MARK: - Preview

struct CategoryButton_Previews: PreviewProvider {
  static var previews: some View {
    CategoryButton(category: .character, isSelected: false)
  }
}
