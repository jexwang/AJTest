//
//  FlickrResponse.swift
//  DemoAPP
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation

struct FlickrResponse: Codable {
    let photos: Photos?
    let code: Int?
    let message: String?
    let stat: String
}
