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
import RxRealm
import RealmSwift

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private var bag: DisposeBag = DisposeBag()
    private var photo: ReplaySubject<Photo> = .create(bufferSize: 1)
    private var isFavorite: ReplaySubject<Bool> = .create(bufferSize: 1)
    private let realm = try! Realm()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        _ = isFavorite
            .takeUntil(rx.deallocated)
            .bind(to: favoriteButton.rx.isSelected)
        
        _ = favoriteButton.rx.tap
            .takeUntil(rx.deallocated)
            .withLatestFrom(Observable.combineLatest(photo, isFavorite))
            .subscribe(onNext: { [weak self] (photo, isFavorite) in
                if isFavorite {
                    if let photoInRealm = self?.realm.objects(Photo.self).first(where: { $0 == photo }) {
                        try! self?.realm.write {
                            self?.realm.delete(photoInRealm)
                        }
                        
                        self?.isFavorite.onNext(false)
                    }
                } else {
                    let storePhoto = photo.detached()
                    try! self?.realm.write {
                        self?.realm.add(storePhoto)
                    }
                    
                    self?.isFavorite.onNext(true)
                }
            })
    }
    
    override func prepareForReuse() {
        bag = DisposeBag()
        photoImageView.image = nil
    }
    
    func configureCell(with photo: Photo) {
        FlickrAPI.shared.getPhoto(photo: photo)
            .drive(photoImageView.rx.image)
            .disposed(by: bag)
        titleLabel.text = photo.title
        
        self.photo.onNext(photo)
        
        Observable.collection(from: realm.objects(Photo.self))
            .withLatestFrom(self.photo) { ($0, $1) }
            .map { (photos, currentPhoto) in
                return currentPhoto.isInvalidated ? false : photos.contains { $0 == currentPhoto }
            }
            .bind(to: isFavorite)
            .disposed(by: bag)
    }
    
    
}
