//
//  String+Extension.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/2.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation

extension String {
    
    var isUnsignedInteger: Bool {
        return range(of: "^[0-9]{1,3}$", options: .regularExpression) != nil
    }
    
}
