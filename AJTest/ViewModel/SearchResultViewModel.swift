//
//  SearchResultViewModel.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/2.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol SearchPhotoAPI {
    func searchPhotos(with searchParameters: SearchParameters, page: Int) -> Single<Photos>
}

class SearchResultViewModel {
    
    private let bag: DisposeBag = DisposeBag()
    
    private let currentPage: BehaviorSubject<Int> = .init(value: 1)
    private let hasNextPage: BehaviorSubject<Bool> = .init(value: false)
    
    let photos: BehaviorRelay<[Photo]> = .init(value: [])
    let onError: PublishSubject<String> = .init()
    
    init(
        input: (
            searchParameters: SearchParameters,
            refresh: Signal<Void>,
            collectionView: UICollectionView
        ),
        searchPhotoAPI: SearchPhotoAPI
    ) {
        input.refresh
            .map { 1 }
            .emit(to: currentPage)
            .disposed(by: bag)
        
        // 下拉更新要先清空 cell，否則數量少於一頁時不會正確觸發 willDisplayCell，導致不會繼續取得後續頁數
        input.refresh
            .map { [] }
            .emit(to: photos)
            .disposed(by: bag)
        
        let getNextPage: Signal<Void> = input.collectionView.rx.willDisplayCell
            .map { $1.item == input.collectionView.numberOfItems(inSection: 0) - 1 }
            .withLatestFrom(hasNextPage) { $0 && $1 }
            .compactMap { $0 ? () : nil }
            .asSignal(onErrorJustReturn: ())
        
        getNextPage
            .withLatestFrom(currentPage.asDriver(onErrorJustReturn: 1))
            .map { $0 + 1 }
            .emit(to: currentPage)
            .disposed(by: bag)
            
        let performSearch = Signal.merge(input.refresh, getNextPage).asObservable()
            .withLatestFrom(currentPage)
            .flatMapLatest { searchPhotoAPI.searchPhotos(with: input.searchParameters, page: $0) }
            .share(replay: 1)
            
        performSearch
            .withLatestFrom(currentPage) { ($0, $1) }
            .subscribe(onNext: { [weak self] (photos, currentPage) in
                photos.pages > currentPage ? self?.hasNextPage.onNext(true) : self?.hasNextPage.onNext(false)
            }, onError: { [weak self] (error) in
                if let error = error as? FlickrAPIError {
                    self?.onError.onNext(error.localizedDescription)
                } else {
                    self?.onError.onNext(error.localizedDescription)
                }
            })
            .disposed(by: bag)
        
        performSearch
            .withLatestFrom(Observable.combineLatest(currentPage, photos) { ($0, $1) }) { (photos, currentPageAndPhotos) -> [Photo] in
                let (currentPage, currentPhotos) = currentPageAndPhotos
                return currentPage == 1 ? photos.photo : currentPhotos + photos.photo.filter { currentPhotos.contains($0) == false }
            }
            .bind(to: photos)
            .disposed(by: bag)
    }
    
}
