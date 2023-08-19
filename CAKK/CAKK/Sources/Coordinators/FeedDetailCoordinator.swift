//
//  FeedDetailCoordinator.swift
//  CAKK
//
//  Created by 이승기 on 2023/08/20.
//


import UIKit

final class FeedDetailCoordinator: Coordinator {
  
  // MARK: - Properties
  
  enum event: CoordinatorEvent { }
  
  var childCoordinators: [any Coordinator] = []
  var navigationController: UINavigationController
  
  let feed: Feed
  let serviceType: NetworkServiceType
  
  
  // MARK: - Initializers
  
  init(navigationController: UINavigationController,
       feed: Feed,
       serviceType: NetworkServiceType) {
    self.navigationController = navigationController
    self.feed = feed
    self.serviceType = serviceType
  }
  
  
  // MARK: - Methods
  
  func start() {
    let service = NetworkService<CakeAPI>(type: serviceType, isLogEnabled: false)
    let viewModel = FeedDetailViewModel(feed: feed,
                                        service: service,
                                        storage: RealmStorage())
    let vc = FeedDetailViewController(viewModel: viewModel)
    vc.modalPresentationStyle = .overFullScreen
    navigationController.present(vc, animated: true)
  }
  
  func eventOccurred(event: FeedDetailCoordinator.event) { }
}
