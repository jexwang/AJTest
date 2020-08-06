//
//  FlickrAPI.swift
//  DemoAPP
//
//  Created by Jay on 2020/7/31.
//  Copyright © 2020 jayisa. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum FlickrAPIError: Error, LocalizedError {
    case url
    case backend(String)
    case dataFormat
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .url:
            return "URL錯誤"
        case .backend(let errorMessage):
            return errorMessage
        case .dataFormat:
            return "資料格式錯誤"
        case .unknown:
            return "發生未知的錯誤"
        }
    }
}

class FlickrAPI: SearchPhotoAPI {
    
    private(set) static var shared: FlickrAPI = FlickrAPI()
    
    private let url: URL? = URL(string: "https://www.flickr.com/")
    private let apiKey: String = "cfc6f20e925ba47a3a366b52a550d474"
    
    private let bag: DisposeBag = DisposeBag()
    private var photosCache: [String: UIImage] = [:]
    
    private init() {
        NotificationCenter.default.rx.notification(UIApplication.didReceiveMemoryWarningNotification)
            .subscribe(onNext: { [weak self] (_) in
                self?.photosCache.removeAll()
            })
            .disposed(by: bag)
    }
    
    func sendRequest<T: Codable>(path: String, queryItems: [URLQueryItem]) -> Single<T> {
        guard let urlWithPath = url?.appendingPathComponent(path) else {
            return .error(FlickrAPIError.url)
        }
        
        var urlComponents = URLComponents(url: urlWithPath, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let fullURL = urlComponents?.url else {
            return .error(FlickrAPIError.url)
        }

        let request = URLRequest(url: fullURL)
        
        return URLSession.shared.rx.data(request: request)
            .observeOn(MainScheduler.instance)
            .flatMap { (data) -> Single<T> in
                do {
                    let dataModel = try JSONDecoder().decode(T.self, from: data)
                    return .just(dataModel)
                } catch {
                    return .error(FlickrAPIError.dataFormat)
                }
            }
            .asSingle()
    }
    
    func searchPhotos(with searchParameters: SearchParameters, page: Int) -> Single<Photos> {
        let queryItems = SearchPhotos(apiKey: apiKey, text: searchParameters.text, perPage: searchParameters.numberOfPhotosPerPage, page: page).getQueryItems()
        return sendRequest(path: "services/rest/", queryItems: queryItems)
            .flatMap { (flickrResponse: FlickrResponse) -> Single<Photos> in
                if flickrResponse.stat == "ok" {
                    if let photos = flickrResponse.photos {
                        return .just(photos)
                    } else {
                        return .error(FlickrAPIError.unknown)
                    }
                } else {
                    if let message = flickrResponse.message {
                        return .error(FlickrAPIError.backend(message))
                    } else {
                        return .error(FlickrAPIError.unknown)
                    }
                }
            }
    }
    
    func getPhoto(photo: Photo) -> Driver<UIImage?> {
        if let image = photosCache[photo.id] {
            return .just(image)
        } else {
            let urlString = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_m.jpg"
            guard let url = URL(string: urlString) else {
                return .just(nil)
            }
            
            let request = URLRequest(url: url)
            return URLSession.shared.rx.data(request: request)
                .observeOn(MainScheduler.instance)
                .retry(3)
                .map { UIImage(data: $0) }
                .do(onNext: { [weak self] (image) in
                    if let image = image {
                        self?.photosCache.updateValue(image, forKey: photo.id)
                    }
                })
                .asDriver(onErrorJustReturn: nil)
        }
    }
    
}
