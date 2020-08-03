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
    let performSearch: Signal<(searchText: String, numberOfPhotosPerPage: Int)>
    
    init(searchText: Driver<String>, numberOfPhotosPerPage: Driver<String>, searchButtonTapped: Signal<Void>) {
        let searchTextAndNumberOfPhotosPerPage = Driver.combineLatest(searchText, numberOfPhotosPerPage)
        
        searchButtonEnabled = searchTextAndNumberOfPhotosPerPage
            .map { $0.count > 0 && $1.count > 0 }
        
        presentAlert = searchButtonTapped.withLatestFrom(numberOfPhotosPerPage.asDriver(onErrorJustReturn: ""))
            .compactMap { $0.isUnsignedInteger ? nil : "請輸入正確數量" }
        
        performSearch = searchButtonTapped.withLatestFrom(searchTextAndNumberOfPhotosPerPage)
            .compactMap { (searchText, numberOfPhotosPerPage) -> (String, Int)? in
                if let numberOfPhotosPerPage = Int(numberOfPhotosPerPage) {
                    return (searchText, numberOfPhotosPerPage)
                } else {
                    return nil
                }
            }
    }
    
}
