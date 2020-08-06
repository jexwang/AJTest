//
//  SearchInputViewModel.swift
//  AJTest
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchInputViewModel {
    
    private let bag: DisposeBag = DisposeBag()
    
    let searchButtonTappable: Driver<Bool>
    let pushSearchResult: Signal<SearchParameters>
    
    let onError: PublishSubject<String> = .init()
    
    init(input: (
            searchText: Driver<String>,
            numberOfPhotosPerPage: Driver<String>,
            searchButtonTapped: Signal<Void>
        )
    ) {
        let textAndNumberOfPhotosPerPage = Driver.combineLatest(input.searchText, input.numberOfPhotosPerPage)
        
        searchButtonTappable = textAndNumberOfPhotosPerPage
            .map { $0 != "" && $1 != "" }
        
        pushSearchResult = input.searchButtonTapped.withLatestFrom(textAndNumberOfPhotosPerPage)
            .compactMap { (text, numberOfPhotosPerPage) in
                if let numberOfPhotosPerPage = Int(numberOfPhotosPerPage) {
                    return (text, numberOfPhotosPerPage)
                } else {
                    return nil
                }
            }
            
        input.searchButtonTapped.withLatestFrom(input.numberOfPhotosPerPage)
            .compactMap { $0.isUnsignedInteger ? nil : "請輸入正確數量\n每頁不可大於999張" }
            .emit(to: onError)
            .disposed(by: bag)
    }
    
}
