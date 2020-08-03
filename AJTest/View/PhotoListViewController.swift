//
//  PhotoListViewController.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/2.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class PhotoListViewController: UIViewController {
    
    static private let numberOfPhotosPerRow: Int = 2
    
    @IBOutlet weak var photoListCollectionView: UICollectionView!
    
    var searchText: String!
    var numberOfPhotosPerPage: Int!
    
    private var currentPage: Int = 1
    
    private let bag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "搜尋結果 \(searchText!)"
        
        searchPhotos()
    }
    
    private func searchPhotos() {
        FlickrAPI.searchPhotos(by: searchText, numberOfPhotoPerPage: numberOfPhotosPerPage, page: currentPage)
            .subscribe(onSuccess: { [weak self] (photos) in
                self?.photoListCollectionView(load: photos.photo)
            }) { [weak self] (error) in
                self?.presentAlert(message: error.localizedDescription)
            }
            .disposed(by: bag)
    }
    
    private func photoListCollectionView(load photos: [Photo]) {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Photo>>(configureCell: { (dataSource, collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
            cell.configureCell(with: item)
            return cell
        })
        
        Observable.just([SectionModel(model: "", items: photos)])
            .bind(to: photoListCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }

}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayot = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("PhotoListCollectionView layout is not FlowLayout.")
        }

        let usedSpacing: CGFloat = flowLayot.sectionInset.left + flowLayot.sectionInset.right + (flowLayot.minimumInteritemSpacing * CGFloat(PhotoListViewController.numberOfPhotosPerRow - 1))
        let width: CGFloat = (collectionView.frame.width - usedSpacing) / CGFloat(PhotoListViewController.numberOfPhotosPerRow)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 {
//            currentPage += 1
//            searchPhotos()
        }
    }
    
}
