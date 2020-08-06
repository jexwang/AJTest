//
//  SearchResultViewController.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/2.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class SearchResultViewController: UIViewController {
    
    static private let numberOfPhotosPerRow: Int = 2
    
    @IBOutlet weak var photoListCollectionView: UICollectionView!
    
    var searchParameters: SearchParameters!
    
    private var viewModel: SearchResultViewModel!
    private let bag: DisposeBag = DisposeBag()
    
    private let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "搜尋結果 \(searchParameters.text)"
        photoListCollectionView.addSubview(refresher)
        
        viewModel = SearchResultViewModel(
            input: (
                searchParameters: searchParameters,
                refresh: refresher.rx.controlEvent(.valueChanged).asSignal(),
                collectionView: photoListCollectionView
            ),
            searchPhotoAPI: FlickrAPI.shared
        )
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Photo>>(configureCell: { (_, collectionView, indexPath, element) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
            cell.configureCell(with: element)
            return cell
        })
        
        viewModel.photos
            .do(onNext: { [weak self] _ in
                self?.refresher.endRefreshing()
            })
            .map { [AnimatableSectionModel(model: "", items: $0)] }
            .bind(to: photoListCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        viewModel.onError
            .subscribe(onNext: { [weak self] in
                self?.presentAlert(message: $0)
            })
            .disposed(by: bag)
        
        // 執行第一次搜尋
        refresher.sendActions(for: .valueChanged)
    }

}

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayot = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("PhotoListCollectionView layout is not FlowLayout.")
        }

        let usedSpacing: CGFloat = flowLayot.sectionInset.left + flowLayot.sectionInset.right + (flowLayot.minimumInteritemSpacing * CGFloat(SearchResultViewController.numberOfPhotosPerRow - 1))
        let width: CGFloat = (collectionView.frame.width - usedSpacing) / CGFloat(SearchResultViewController.numberOfPhotosPerRow)
        return CGSize(width: width, height: width)
    }
    
}
