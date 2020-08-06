//
//  SearchInputViewController.swift
//  AJTest
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SearchInputViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var numberOfPhotosPerPageTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    private var viewModel: SearchInputViewModel!
    private let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        viewModel = SearchInputViewModel(
            input: (
                searchText: searchTextField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
                numberOfPhotosPerPage: numberOfPhotosPerPageTextField.rx.text.orEmpty.asDriver(onErrorJustReturn: ""),
                searchButtonTapped: searchButton.rx.tap.asSignal()
            )
        )
        
        viewModel.searchButtonTappable
            .drive(onNext: { [weak self] (isEnabled) in
                self?.searchButton.isEnabled = isEnabled
                self?.searchButton.backgroundColor = isEnabled ? .systemBlue : .systemGray2
            })
            .disposed(by: bag)
        
        viewModel.pushSearchResult
            .emit(onNext: { [weak self] (searchParameters) in
                self?.pushSearchResultVC(with: searchParameters)
            })
            .disposed(by: bag)
            
        viewModel.onError
            .subscribe(onNext: { [weak self] (message) in
                self?.presentAlert(message: message)
            })
            .disposed(by: bag)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
    private func pushSearchResultVC(with searchParameters: SearchParameters) {
        guard let searchResultVC = storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else {
            fatalError("尚未正確設定 SearchResultViewController")
        }
        
        searchResultVC.searchParameters = searchParameters
        navigationController?.pushViewController(searchResultVC, animated: true)
    }
    
}
