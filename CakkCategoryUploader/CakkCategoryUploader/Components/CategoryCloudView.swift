//
//  CategoryCloudView.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import SwiftUI

struct CategoryCloudView: View {
  
  // MARK: - Properties
  
  @EnvironmentObject var store: PostingViewStore
  var categories: [CakeCategory]
  
  @State private var totalHeight
  = CGFloat.zero       // << variant for ScrollView/List
  //    = CGFloat.infinity   // << variant for VStack
  
  
  
  // MARK: - Views
  
  var body: some View {
    VStack {
      GeometryReader { geometry in
        self.generateContent(in: geometry)
      }
    }
    .frame(height: totalHeight)// << variant for ScrollView/List
    //.frame(maxHeight: totalHeight) // << variant for VStack
  }
  
  private func generateContent(in g: GeometryProxy) -> some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    
    return ZStack(alignment: .topLeading) {
      ForEach(self.categories, id: \.self) { category in
        CategoryButton(category: category, isSelected: store.isSelected(category))
          .padding([.horizontal, .vertical], 4)
          .alignmentGuide(.leading, computeValue: { d in
            if (abs(width - d.width) > g.size.width)
            {
              width = 0
              height -= d.height
            }
            let result = width
            if category == self.categories.last! {
              width = 0 //last item
            } else {
              width -= d.width
            }
            return result
          })
          .alignmentGuide(.top, computeValue: {d in
            let result = height
            if category == self.categories.last! {
              height = 0 // last item
            }
            return result
          })
      }
    }.background(viewHeightReader($totalHeight))
  }
  
  private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
    return GeometryReader { geometry -> Color in
      let rect = geometry.frame(in: .local)
      DispatchQueue.main.async {
        binding.wrappedValue = rect.size.height
      }
      return .clear
    }
  }
}
