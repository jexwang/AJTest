//
//  UIViewController+Extension.swift
//  AJTest
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlert(title: String? = "錯誤", message: String?, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            action?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}
