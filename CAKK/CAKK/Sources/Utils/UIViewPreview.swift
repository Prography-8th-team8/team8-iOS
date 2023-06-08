//
//  UIViewPreview.swift
//  CAKK
//
//  Created by 이승기 on 2023/04/25.
//

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct UIViewPreview<View: UIView>: UIViewRepresentable {
  let view: View
  
  init(_ content: @escaping () -> View) {
    view = content()
  }
  
  func makeUIView(context: Context) -> some UIView {
    return view
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}
#endif
