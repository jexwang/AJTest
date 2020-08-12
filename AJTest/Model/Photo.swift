//
//  Photo.swift
//  DemoAPP
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxDataSources
import RealmSwift

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

class Photo: Object, Codable, IdentifiableType {
    
    typealias Identity = String
    var identity: String {
        return id
    }
    
    @objc dynamic var id: String
    @objc dynamic var owner: String     
    @objc dynamic var secret: String
    @objc dynamic var server: String
    @objc dynamic var farm: Int
    @objc dynamic var title: String
    @objc dynamic var ispublic: Int
    @objc dynamic var isfriend: Int
    @objc dynamic var isfamily: Int
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
}
