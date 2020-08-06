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
            input: (
                searchText: searchTextField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
                numberOfPhotosPerPage: numberOfPhotosPerPageTextField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
                searchButtonTapped: searchButton.rx.tap.asSignal()
            )
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
            .emit(onNext: { [weak self] (params) in
                PhotoManager.shared.searchPhotos(params: params)
                self?.performSegue(withIdentifier: "ToPhotoList", sender: nil)
            })
            .disposed(by: bag)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
}
