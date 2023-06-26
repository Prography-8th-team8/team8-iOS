//
//  PostingView.swift
//  CakkCategoryUploader
//
//  Created by 이승기 on 2023/06/26.
//

import SwiftUI

struct PostingView: View {
  
  // MARK: - Properties
  
  @Environment(\.presentationMode) var presentationMode
  @StateObject var store: PostingViewStore
  @State var isHidden = false
  
  
  // MARK: - Preview
  
  var body: some View {
    ZStack {
      WebView(url: store.cakeShop.url ?? "")
        .navigationTitle(store.cakeShop.name)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom, 100)
      
      VStack {
        Spacer()
        
        VStack {
          if isHidden == false {
            VStack {
              HStack {
                Text("해당되는 카테고리를 모두 선택해 주세요😊")
                  .font(.system(size: 16, weight: .bold))
                  .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                  withAnimation(.spring()) {
                    isHidden.toggle()
                  }
                } label: {
                  Image(systemName: "chevron.down")
                }
              }
              
              CategoryCloudView(categories: store.categories)
              
              Spacer()
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 16)
          } else {
            VStack {
              Button {
                withAnimation(.spring()) {
                  isHidden.toggle()
                }
              } label: {
                HStack {
                  Text("펼치기")
                    .font(.system(size: 14, weight: .bold))
                  
                  Image(systemName: "chevron.up")
                }
              }
              .padding()
              .foregroundColor(.black)
              
              Spacer()
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: isHidden ? 100 : 230)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 40)
      }
      
      
      VStack {
        Spacer()
        
        Button {
          store.post()
        } label: {
          Text("등록")
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: 48)
        }
        .background(Color.accentColor.edgesIgnoringSafeArea(.all))
      }
    }
    .environmentObject(store)
    .alert("업로드에 성공하였습니다!", isPresented: $store.isSuccessToUpload) {
      Button(role: .none) {
        presentationMode.wrappedValue.dismiss()
      } label: {
        Text("확인")
      }
    }
  }
}


// MARK: - Preview

struct PostingView_Previews: PreviewProvider {
  static var previews: some View {
    let store = PostingViewStore(cakeShop: .init(
      id: 0,
      createdAt: "",
      modifiedAt: "",
      name: "케이크집 이름",
      city: "",
      district: .dobong,
      location: "",
      latitude: 0,
      longitude: 0,
      cakeCategories: [],
      url: "https://www.naver.com/"))
    PostingView(store: store)
  }
}
