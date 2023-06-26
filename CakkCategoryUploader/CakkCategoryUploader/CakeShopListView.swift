//
//  CakeShopListView.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import SwiftUI

struct CakeShopListView: View {
  
  // MARK: - Properties
  
  @State var cakeShops: [CakeShop]
  
  @StateObject var postedCakeShop = PostedCakeShopUserDefault.shared
  
  
  // MARK: - Initializers
  
  init(cakeShops: [CakeShop]) {
    _cakeShops = .init(wrappedValue: cakeShops)
  }
  
  
  // MARK: - Views
  
  var body: some View {
    List(cakeShops, id: \.self) { cakeShop in
      NavigationLink {
        let store = PostingViewStore(cakeShop: cakeShop)
        PostingView(store: store)
      } label: {
        if postedCakeShop.publishedValue[cakeShop.name] ?? false {
          Text("🍰 \(cakeShop.name)")
        } else {
          Text(cakeShop.name)
        }
      }
    }
    .navigationTitle("케이크샵")
    .navigationBarTitleDisplayMode(.inline)
  }
}


// MARK: - Preview

struct CakeShopListView_Previews: PreviewProvider {
  static var previews: some View {
    CakeShopListView(cakeShops: [])
  }
}
