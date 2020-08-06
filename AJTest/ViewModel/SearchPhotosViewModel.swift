//
//  SearchPhotosViewModel.swift
//  AJTest
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchPhotosViewModel {
    
    let searchButtonEnabled: Driver<Bool>
    let presentAlert: Signal<String>
    let performSearch: Signal<SearchParameters>
    
    init(input: (
            searchText: Driver<String>,
            numberOfPhotosPerPage: Driver<String>,
            searchButtonTapped: Signal<Void>
        )
    ) {
        let searchTextAndNumberOfPhotosPerPage = Driver.combineLatest(input.searchText, input.numberOfPhotosPerPage)
        
        searchButtonEnabled = searchTextAndNumberOfPhotosPerPage
            .map { $0.count > 0 && $1.count > 0 }
        
        presentAlert = input.searchButtonTapped.withLatestFrom(input.numberOfPhotosPerPage)
            .compactMap { $0.isUnsignedInteger ? nil : "請輸入正確數量" }
        
        performSearch = input.searchButtonTapped.withLatestFrom(searchTextAndNumberOfPhotosPerPage)
            .compactMap { (searchText, numberOfPhotosPerPage) in
                if let numberOfPhotosPerPage = Int(numberOfPhotosPerPage) {
                    return (searchText, numberOfPhotosPerPage)
                } else {
                    return nil
                }
            }
    }
    
}
