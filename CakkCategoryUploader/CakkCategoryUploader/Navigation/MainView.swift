//
//  MainView.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/23.
//

import SwiftUI

struct MainView: View {
  
  // MARK: - Properties
  
  @State var didAppear = false
  @State var cakeShops = [CakeShop]()
  @State var namesWithRange = [NameWithRange]()
  
  struct NameWithRange {
    var name: String
    var cakeShops: [CakeShop]
  }
  
  
  // MARK: - Views
  
  var body: some View {
    NavigationView {
      List(namesWithRange, id: \.name) { nameWithRange in
        NavigationLink {
          CakeShopListView(cakeShops: nameWithRange.cakeShops)
        } label: {
          Text(nameWithRange.name)
            .frame(height: 40)
        }
      }
      .listStyle(.plain)
      .navigationTitle("파트 분류")
    }
    .onAppear {
      if didAppear == false {
        loadData()
        didAppear = true
      }
    }
  }
  
  
  // MARK: - Methods
  
  private func loadData() {
    let location = Bundle.main.url(forResource: "cake_shop_list_sample", withExtension: "json")!
    let data = try! Data(contentsOf: location)
    let cakeShops = try! JSONDecoder().decode([CakeShop].self, from: data)
    
    namesWithRange = [
      NameWithRange(name: "👨‍🏫 염준우", cakeShops: Array(cakeShops[0..<38])),
      NameWithRange(name: "🍎 이승기", cakeShops: Array(cakeShops[39..<77])),
      NameWithRange(name: "🍎 김대황", cakeShops: Array(cakeShops[78..<116])),
      NameWithRange(name: "🤖 오원석", cakeShops: Array(cakeShops[117..<155])),
      NameWithRange(name: "🤖 이준경", cakeShops: Array(cakeShops[156..<194])),
      NameWithRange(name: "🎨 서해나", cakeShops: Array(cakeShops[195..<233])),
      NameWithRange(name: "🎨 오승민", cakeShops: Array(cakeShops[234..<272])),
      NameWithRange(name: "🗼 배지현", cakeShops: Array(cakeShops[273..<311])),
      NameWithRange(name: "🗼 박영민", cakeShops: Array(cakeShops[312..<344])),
    ]
  }
}


// MARK: - Preview

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
