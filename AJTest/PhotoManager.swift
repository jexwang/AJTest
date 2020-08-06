//
//  PhotoManager.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/4.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

typealias SearchParameters = (text: String, numberOfPhotosPerPage: Int)

class PhotoManager {
    
    static private(set) var shared: PhotoManager = PhotoManager()
    
    private let bag: DisposeBag = DisposeBag()
    
    private(set) var searchParameters: ReplaySubject<SearchParameters> = .create(bufferSize: 1)
    
    private let searchPhotos: PublishSubject<Void> = .init()
    private let currentPage: BehaviorSubject<Int> = .init(value: 1)
    
    let photos: BehaviorRelay<[Photo]> = .init(value: [])
    let hasNextPage: BehaviorSubject<Bool> = .init(value: false)
    let onError: PublishSubject<String> = .init()
    
    private init() {
        let searchResult = searchPhotos
            .withLatestFrom(Observable.combineLatest(searchParameters, currentPage))
            .flatMap { FlickrAPI.searchPhotos(by: $0.text, numberOfPhotoPerPage: $0.numberOfPhotosPerPage, page: $1) }
            .share(replay: 1)
        
        searchResult
            .withLatestFrom(photos) { ($0, $1) }
            .map({ (photos, currentPhotos) in
                return currentPhotos + photos.photo.filter({ currentPhotos.contains($0) == false })
            })
            .asDriver(onErrorJustReturn: [])
            .drive(photos)
            .disposed(by: bag)
        
        searchResult
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
    }
    
    func searchPhotos(params: SearchParameters? = nil) {
        if let params = params {
            searchParameters.onNext(params)
        }

        currentPage.onNext(1)
        hasNextPage.onNext(false)
        photos.accept([])
        
        searchPhotos.onNext(())
    }
    
    func nextPage() {
        guard (try? hasNextPage.value()) == true else { return }
        
        if let currentPage = try? currentPage.value() {
            self.currentPage.onNext(currentPage + 1)
        }
        
        searchPhotos.onNext(())
    }
    
}
