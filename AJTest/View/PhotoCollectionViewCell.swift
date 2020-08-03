//
//  PhotoCollectionViewCell.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/3.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var bag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func configureCell(with photo: Photo) {
        FlickrAPI.getPhoto(photo: photo)
            .drive(photoImageView.rx.image)
            .disposed(by: bag)
        titleLabel.text = photo.title
    }
    
}
