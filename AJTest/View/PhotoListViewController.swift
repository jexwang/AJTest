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
    
    private var viewModel: PhotoListViewModel!
    private let bag: DisposeBag = DisposeBag()
    
    private let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        PhotoManager.shared.searchParameters
            .subscribe(onNext: { [weak self] (params) in
                self?.navigationItem.title = "搜尋結果 \(params.text)"
            })
            .disposed(by: bag)
        
        refresher.rx.controlEvent(.valueChanged)
            .subscribe(onNext: {
                PhotoManager.shared.searchPhotos()
            })
            .disposed(by: bag)
        photoListCollectionView.addSubview(refresher)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Photo>>(configureCell: { (_, collectionView, indexPath, element) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
            cell.configureCell(with: element)
            return cell
        })
        
        PhotoManager.shared.photos
            .do(onNext: { [weak self] _ in self?.refresher.endRefreshing() })
            .map { [AnimatableSectionModel(model: "", items: $0)] }
            .bind(to: photoListCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        photoListCollectionView.rx.willDisplayCell
            .map { $1 }
            .withLatestFrom(PhotoManager.shared.photos) { $0.item == $1.count - 1 }
            .withLatestFrom(PhotoManager.shared.hasNextPage) { ($0, $1) }
            .subscribe(onNext: { (willDisplayLastCell, hasNextPage) in
                if willDisplayLastCell && hasNextPage {
                    PhotoManager.shared.nextPage()
                }
            })
            .disposed(by: bag)
        
        PhotoManager.shared.onError
            .subscribe(onNext: { [weak self] in self?.presentAlert(message: $0) })
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
    
}
