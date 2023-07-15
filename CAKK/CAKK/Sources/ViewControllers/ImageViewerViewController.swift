//
//  ImageViewerViewController.swift
//  CAKK
//
//  Created by 이승기 on 2023/07/14.
//

import UIKit

import SnapKit
import Then
import Hero

class ImageViewerViewController: UIViewController {
  
  // MARK: - Properties
  
  private let imageUrl: String
  
  
  // MARK: - UI
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  
  // MARK: - Initializers
  
  init(imageUrl: String) {
    self.imageUrl = imageUrl
    super.init(nibName: nil, bundle: nil)
    
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Private
  
  @objc
  private func didPan(_ sender: UIPanGestureRecognizer) {
    let translate = sender.translation(in: view)
    let distanceY = abs(view.frame.origin.y - abs(imageView.frame.origin.y))
    let velocity = sender.velocity(in: view)
    let dismissThreshold = 160.f
    
    if distanceY > dismissThreshold {
      imageView.frame.origin.x += translate.x * 0.5
      imageView.frame.origin.y += translate.y * 0.5
    } else {
      imageView.frame.origin.x += translate.x
      imageView.frame.origin.y += translate.y
    }
    
    if sender.state == .ended {
      if distanceY > dismissThreshold ||
          abs(velocity.x) > 100 ||
          abs(velocity.y) > 100 {
        dismiss(animated: true)
      } else {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8) {
          self.imageView.frame.origin = self.view.frame.origin
        }
      }
    }
    
    sender.setTranslation(.zero, in: view)
  }
  
  @objc
  func didTap(_ sender: UITapGestureRecognizer) {
    dismiss(animated: true)
  }
}


// MARK: - UI & Layout

extension ImageViewerViewController {
  
  private func setup() {
    setupLayout()
    setupView()
  }
  
  private func setupLayout() {
    view.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupView() {
    setupBaseView()
    setupImageView()
  }
  
  private func setupBaseView() {
    hero.isEnabled = true
    
    // background as dimming
    view.backgroundColor = .black.withAlphaComponent(0.8)
    
    // tap gesture
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
    view.addGestureRecognizer(tapGestureRecognizer)
    
    // hero
    view.hero.modifiers = [.fade, .duration(0.25)]
  }
  
  private func setupImageView() {
    let url = URL(string: imageUrl)
    imageView.kf.setImage(with: url)
    
    // pan gesture
    imageView.isUserInteractionEnabled = true
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
    imageView.addGestureRecognizer(panGestureRecognizer)
    
    // hero
    imageView.hero.modifiers = [.scale(0.5), .duration(0.25)]
  }
}


// MARK: - Preview
import SwiftUI

struct ImageViewerViewController_Preview: PreviewProvider {
  
  static var previews: some View {
    ZStack {
      VStack {
        Text("Hello word")
        
        Spacer()
      }
      .padding(24)
      
      let imageUrl = "https://bucket-8th-team8.s3.ap-northeast-2.amazonaws.com/cakk/store/f26fe985-c10e-463c-8793-4fffe13ae2ef.jpeg"
      ImageViewerViewController(imageUrl: imageUrl).toPreview()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
  }
}
