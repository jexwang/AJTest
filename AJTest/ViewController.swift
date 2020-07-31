//
//  ViewController.swift
//  AJTest
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        FlickrAPI.searchPhotos(by: "Food", numberOfPhotoPerPage: 4, page: 1) { [weak self] (result) in
            switch result {
            case .success(let photos):
                print(photos)
            case .failure(let error):
                self?.presentAlert(message: error.localizedDescription)
            }
        }
    }


}

