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
    case request(String)
    case backend(String)
    case dataFormat
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .url:
            return "URL錯誤"
        case .request(let errorMessage):
            return errorMessage
        case .backend(let errorMessage):
            return errorMessage
        case .dataFormat:
            return "資料格式錯誤"
        case .unknown:
            return "發生未知的錯誤"
        }
    }
}

class FlickrAPI {
    
    static private let url = URL(string: "https://www.flickr.com/")
    static private let apiKey = "cfc6f20e925ba47a3a366b52a550d474"
    
    static private let bag = DisposeBag()
    
    static func sendRequest<T: Codable>(path: String, queryItems: [URLQueryItem], completion: @escaping (_ result: Result<T, FlickrAPIError>) -> Void) {
        guard let urlWithPath = url?.appendingPathComponent(path) else {
            completion(.failure(.url))
            return
        }
        
        var urlComponents = URLComponents(url: urlWithPath, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let fullURL = urlComponents?.url else {
            completion(.failure(.url))
            return
        }

        let request = URLRequest(url: fullURL)
        
        URLSession.shared.rx.data(request: request)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.dataFormat))
                }
            }, onError: { (error) in
                completion(.failure(.request(error.localizedDescription)))
            })
            .disposed(by: bag)
    }
    
    static func searchPhotos(by text: String, numberOfPhotoPerPage: Int, page: Int, completion: @escaping (_ result: Result<Photos, FlickrAPIError>) -> Void) {
        let queryItems = SearchPhotos(apiKey: apiKey, text: text, perPage: numberOfPhotoPerPage, page: page).getQueryItems()
        sendRequest(path: "services/rest/", queryItems: queryItems) { (result: Result<FlickrResponse, FlickrAPIError>) in
            switch result {
            case .success(let flickrResponse):
                if flickrResponse.stat == "ok" {
                    if let photos = flickrResponse.photos {
                        completion(.success(photos))
                    } else {
                        completion(.failure(.unknown))
                    }
                } else {
                    if let message = flickrResponse.message {
                        completion(.failure(.backend(message)))
                    } else {
                        completion(.failure(.unknown))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
