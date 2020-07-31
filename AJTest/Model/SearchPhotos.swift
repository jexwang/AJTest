//
//  SearchPhoto.swift
//  DemoAPP
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation

struct SearchPhotos {
    let method = "flickr.photos.search"
    let apiKey: String
    let text: String
    let perPage: Int
    let page: Int
    let format = "json"
    let noJSONCallback = 1
    
    func getQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "format", value: format),
            URLQueryItem(name: "nojsoncallback", value: "\(noJSONCallback)")
        ]
    }
}
