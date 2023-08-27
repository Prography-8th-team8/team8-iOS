//
//  MyBookmarkCellViewModel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/08/07.
//

import UIKit

import Combine

class MyBookmarkCellViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let tapBookmarkButton = PassthroughSubject<Void, Never>()
  }
  
  struct Output {
    let isBookmarked = CurrentValueSubject<Bool, Never>(true)
    let showBookmarkToast = PassthroughSubject<Bool, Never>()
  }
  
  let input: Input
  let output: Output
  private var cancellableBag = Set<AnyCancellable>()
  
  let bookmark: Bookmark
  private let realmStorage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(bookmark: Bookmark,
       realmStorage: RealmStorageProtocol) {
    self.bookmark = bookmark
    self.realmStorage = realmStorage
    
    self.input = Input()
    self.output = Output()
    bind(input, output)
  }
  
  
  // MARK: - Binds
  
  private func bind(_ input: Input, _ output: Output) {
    bindBookmark(input, output)
    bindBookmarkToast(input, output)
  }

  private func bindBookmark(_ input: Input, _ output: Output) {
    let isBookmarked = realmStorage.load(id: bookmark.id, entityType: BookmarkEntity.self) != nil
    output.isBookmarked.send(isBookmarked)
    
    let bookmark = bookmark
    input.tapBookmarkButton
      .sink { _ in
        if output.isBookmarked.value {
          // 북마크 삭제
          let successToRemove = self.realmStorage.remove(id: bookmark.id,
                                                         entityType: BookmarkEntity.self)
          
          if successToRemove {
            output.isBookmarked.send(false)
          }
        } else {
          // 북마크 추가
          let entity = bookmark.toEntity()
          let successToSave = self.realmStorage.save(entity)
          
          if successToSave {
            output.isBookmarked.send(true)
          }
        }
      }
      .store(in: &cancellableBag)
  }
  
  private func bindBookmarkToast(_ input: Input, _ output: Output) {
    input.tapBookmarkButton
      .sink { _ in
        let isBookmarked = output.isBookmarked.value
        output.showBookmarkToast.send(!isBookmarked)
      }
      .store(in: &cancellableBag)
  }
}
