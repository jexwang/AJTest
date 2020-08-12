//
//  MyFavoriteViewController.swift
//  AJTest
//
//  Created by 王冠綸 on 2020/8/10.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit
import RxSwift

class MyFavoriteViewController: UIViewController {
    
    static private let numberOfPhotosPerRow: Int = 2
    
    @IBOutlet weak var photoListCollectionView: UICollectionView!
    
    private var viewModel: MyFavoriteViewModel!
    private let bag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel = MyFavoriteViewModel()
        
        viewModel.photos
            .bind(to: photoListCollectionView.rx.items(cellIdentifier: "Cell")) { index, model, cell in
                if let cell = cell as? PhotoCollectionViewCell {
                    cell.configureCell(with: model)
                }
            }
            .disposed(by: bag)
    }

}

extension MyFavoriteViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayot = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("PhotoListCollectionView layout is not FlowLayout.")
        }

        let usedSpacing: CGFloat = flowLayot.sectionInset.left + flowLayot.sectionInset.right + (flowLayot.minimumInteritemSpacing * CGFloat(MyFavoriteViewController.numberOfPhotosPerRow - 1))
        let width: CGFloat = (collectionView.frame.width - usedSpacing) / CGFloat(MyFavoriteViewController.numberOfPhotosPerRow)
        return CGSize(width: width, height: width)
    }
    
}

