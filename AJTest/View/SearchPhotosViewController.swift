//
//  SearchPhotosViewController.swift
//  AJTest
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchPhotosViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var numberOfPhotosPerPageTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    private var viewModel: SearchPhotosViewModel!
    private let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        viewModel = SearchPhotosViewModel(
            searchText: searchTextField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
            numberOfPhotosPerPage: numberOfPhotosPerPageTextField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
            searchButtonTapped: searchButton.rx.tap.asSignal()
        )
        
        viewModel.searchButtonEnabled
            .drive(onNext: { [weak self] (isEnabled) in
                self?.searchButton.isEnabled = isEnabled
                self?.searchButton.backgroundColor = isEnabled ? .systemBlue : .systemGray2
            })
            .disposed(by: bag)
        
        viewModel.presentAlert
            .emit(onNext: { [weak self] (message) in
                self?.presentAlert(message: message)
            })
            .disposed(by: bag)
        
        viewModel.performSearch
            .emit(onNext: { [weak self] (searchText, numberOfPhotosPerPage) in
                self?.view.endEditing(true)
                
                if let photoListVC = self?.storyboard?.instantiateViewController(withIdentifier: "PhotoListViewController") as? PhotoListViewController {
                    photoListVC.searchText = searchText
                    photoListVC.numberOfPhotosPerPage = numberOfPhotosPerPage
                    self?.navigationController?.pushViewController(photoListVC, animated: true)
                }
            })
            .disposed(by: bag)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
}
