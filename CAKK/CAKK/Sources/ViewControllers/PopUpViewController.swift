//
//  PopUpViewController.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import UIKit

import Combine
import CombineCocoa

import SnapKit
import Then


class PopUpViewController: UIViewController {
  
  // MARK: - Properties
  
  private let titleText: String
  private let descriptionText: String?
  
  private var confirmAction: () -> Void
  private var cancelAction: (() -> Void)?
  
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI
  
  private let contentView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 14
    $0.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
  }
  
  private lazy var titleLabel = UILabel().then {
    $0.text = titleText
    $0.textAlignment = .center
    $0.font = .pretendard(size: 18, weight: .semiBold)
  }
  
  private lazy var descriptionLabel = descriptionText == nil ? nil : UILabel().then {
    $0.text = descriptionText
    $0.textAlignment = .center
    $0.font = .pretendard()
  }
  
  private lazy var titleDescriptionStackView = UIStackView().then { stack in
    stack.spacing = 8
    stack.axis = .vertical
    
    stack.addArrangedSubview(titleLabel)
    if let descriptionLabel {
      stack.addArrangedSubview(descriptionLabel)
    }
  }
  
  private let cancelButton = UIButton().then {
    $0.setTitle("취소", for: .normal)
    $0.setTitleColor(R.color.gray_60(), for: .normal)
    $0.setTitleColor(R.color.gray_10(), for: .highlighted)
    $0.titleLabel?.font = .pretendard(size: 16)
    $0.backgroundColor = R.color.gray_10()
    $0.layer.cornerRadius = 12
  }
  
  private let confirmButton = UIButton().then {
    $0.setTitle("확인", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.setTitleColor(.white.withAlphaComponent(0.2), for: .highlighted)
    $0.titleLabel?.font = .pretendard(size: 16, weight: .semiBold)
    $0.backgroundColor = R.color.pink_100()
    $0.layer.cornerRadius = 12
  }
  
  private lazy var buttonStackView = UIStackView(arrangedSubviews: [
    cancelButton, confirmButton
  ]).then {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.distribution = .fillEqually
  }
  
  
  // MARK: - Initializers
  
  init(titleText: String,
       descriptionText: String? = nil,
       confirmAction: @escaping () -> Void,
       cancelAction: (() -> Void)? = nil) {
    self.titleText = titleText
    self.descriptionText = descriptionText
    self.confirmAction = confirmAction
    self.cancelAction = cancelAction
    
    super.init(nibName: nil, bundle: nil)
    
    modalPresentationStyle = .overFullScreen
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
      self?.contentView.transform = .identity
      self?.contentView.isHidden = false
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [weak self] in
      self?.contentView.transform = .identity
      self?.contentView.isHidden = true
    }
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupView()
    setupLayout()
  }
  
  private func bind() {
    confirmButton.tapPublisher.sink { [weak self] in
      self?.confirmAction()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self?.dismiss(animated: false)
      }
    }
    .store(in: &cancellables)
    
    cancelButton.tapPublisher.sink { [weak self] in
      self?.cancelAction?()
      self?.dismiss(animated: false)
    }
    .store(in: &cancellables)
  }
}


// MARK: - UI & Layouts

extension PopUpViewController {
  
  private func setupView() {
    view.backgroundColor = .black.withAlphaComponent(0.6)
  }
  
  // MARK: - Setup Layout
  
  private func setupLayout() {
    setupContainerViewLayout()
    setupTitleDescriptionStackViewLayout()
    setupButtonStackViewLayout()
  }
  
  private func setupContainerViewLayout() {
    view.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.horizontalEdges.equalToSuperview().inset(24)
    }
  }
  
  private func setupTitleDescriptionStackViewLayout() {
    contentView.addSubview(titleDescriptionStackView)
    titleDescriptionStackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(16)
      $0.top.equalToSuperview().inset(48)
    }
  }
  
  private func setupButtonStackViewLayout() {
    contentView.addSubview(buttonStackView)
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(titleDescriptionStackView.snp.bottom).offset(36)
      $0.horizontalEdges.bottom.equalToSuperview().inset(16)
      $0.height.equalTo(44)
    }
  }
}

// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct PopUpViewController_Preview: PreviewProvider {
  static var previews: some View {
    PopUpViewController(titleText: "네이버 지도에서 여시겠어요?",
                        descriptionText: "확인을 누르신다면 이동을 할 것이에요.\n확인을 누르신다면 이동을 할 것이에요.",
                        confirmAction: {}).toPreview()
  }
}
#endif
