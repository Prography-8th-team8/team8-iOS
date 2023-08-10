//
//  UICollectionView+RegisterDequeue.swift
//  CAKK
//
//  Created by Mason Kim on 2023/06/11.
//

import UIKit

// MARK: - 컬렉션뷰의 Cell, Header를 쉽게 register, dequeue 하기 위한 Syntax Sugar 메서드들

extension UICollectionReusableView: ReusableView {}

extension UICollectionView {
  func registerCell<T: UICollectionViewCell>(cellClass: T.Type) {
    register(cellClass, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(cellClass: T.Type,
                                                    for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError("Unable to dequeue Reusable CollectionView cell")
    }
    return cell
  }
  
  func registerSupplementaryView<T: UICollectionReusableView>(viewClass: T.Type,
                                                              forSupplementaryViewOfKind: String) {
    register(viewClass,
             forSupplementaryViewOfKind: forSupplementaryViewOfKind,
             withReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerHeaderView<T: UICollectionReusableView>(viewClass: T.Type) {
    register(viewClass,
             forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
             withReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerFooterView<T: UICollectionReusableView>(viewClass: T.Type) {
    register(viewClass,
             forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
             withReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String,
                                                                     viewType: T.Type,
                                                                     for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: elementKind,
                                                      withReuseIdentifier: T.reuseIdentifier,
                                                      for: indexPath) as? T else {
      fatalError("Unable to dequeue Reusable CollectionView ReusableView: \(viewType)")
    }
    return view
  }
  
  func dequeueReusableHeaderView<T: UICollectionReusableView>(ofType viewType: T.Type,
                                                              for indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                            viewType: viewType,
                                            for: indexPath)
  }
  
  func dequeueReusableFooterView<T: UICollectionReusableView>(ofType viewType: T.Type,
                                                              for indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                            viewType: viewType,
                                            for: indexPath)
  }
}
