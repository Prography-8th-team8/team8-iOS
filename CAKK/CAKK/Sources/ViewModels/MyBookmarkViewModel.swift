//
//  MyBookmarkViewModel.swift
//  CAKK
//
//  Created by Mason Kim on 2023/07/30.
//

import Foundation

import Combine


final class MyBookmarkViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    let viewWillAppear = PassthroughSubject<Void, Never>()
    let tapBookmark = PassthroughSubject<Bookmark, Never>()
  }
  
  struct Output {
    let bookmarks = CurrentValueSubject<[Bookmark], Never>([])
  }
  
  let input: Input
  let output: Output
  private var cancellables = Set<AnyCancellable>()
  
  private let realmStorage: RealmStorageProtocol
  
  
  // MARK: - Initializers
  
  init(realmStorage: RealmStorageProtocol) {
    self.input = Input()
    self.output = Output()
    self.realmStorage = realmStorage
    
    bind(input, output)
  }
  
  
  // MARK: - Private
  
  private func bind(_ input: Input, _ output: Output) {
    input.viewWillAppear.sink { [weak self] in
      guard let self = self else { return }
      let bookmarks = realmStorage
        .loadAll(entityType: BookmarkEntity.self)
        .map { $0.toModel() }
        // 일단 이름 기준 가나다순으로 정렬
        .sorted(by: { $0.name < $1.name })
      
      output.bookmarks.send(bookmarks)
    }
    .store(in: &cancellables)
    
    bindBookmark(input, output)
  }
  
  private func bindBookmark(_ input: Input, _ output: Output) {
    input.tapBookmark.sink { [weak self] bookmark in
      guard let self = self else { return }
      
      if bookmark.isBookmarked {
        realmStorage.remove(id: bookmark.id, entityType: BookmarkEntity.self)
      } else {
        realmStorage.save(bookmark.toEntity())
      }
      
      let updatedBookmarks = updatedBookmarks(withToggle: bookmark, in: output.bookmarks.value)
      output.bookmarks.send(updatedBookmarks)
    }
    .store(in: &cancellables)
  }
  
  /// 북마크의 `isBookmarked` 상태를 토글하고 해당 배열을 리턴
  private func updatedBookmarks(withToggle bookmarkToToggle: Bookmark,
                                in bookmarks: [Bookmark]) -> [Bookmark] {
    var newBookmarks = bookmarks
    if let indexToToggle = newBookmarks.firstIndex(where: { $0 == bookmarkToToggle }) {
      newBookmarks[indexToToggle].isBookmarked.toggle()
    }
    return newBookmarks
  }
}
