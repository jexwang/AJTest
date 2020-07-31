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
    let toPhotoList: Signal<Void>
    
    init(searchText: Observable<String>, numberOfPhotosPerPage: Observable<String>, searchButtonTapped: Signal<Void>) {
        searchButtonEnabled = Observable.combineLatest(searchText, numberOfPhotosPerPage, resultSelector: { $0.count > 0 && $1.count > 0 })
            .asDriver(onErrorJustReturn: false)
        
        presentAlert = searchButtonTapped.asObservable().withLatestFrom(numberOfPhotosPerPage)
            .compactMap { Int($0) == nil ? "請輸入正確數量": nil }
            .asSignal(onErrorSignalWith: .never())
            
        toPhotoList = searchButtonTapped.asObservable().withLatestFrom(numberOfPhotosPerPage)
            .compactMap { Int($0) != nil ? () : nil }
            .asSignal(onErrorSignalWith: .never())
    }
    
}
