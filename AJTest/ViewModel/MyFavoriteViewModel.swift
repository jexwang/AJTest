//
//  MyFavoriteViewModel.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/12.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RealmSwift

class MyFavoriteViewModel {
    
    private let bag: DisposeBag = DisposeBag()
    private let realm: Realm = try! Realm()
    
    let photos: BehaviorRelay<[Photo]> = .init(value: [])
    
    init() {
        Observable.collection(from: realm.objects(Photo.self))
            .map({ $0.toArray() })
            .bind(to: photos)
            .disposed(by: bag)
    }
    
}
