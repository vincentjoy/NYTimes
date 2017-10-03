//
//  WebService.swift
//  NYTimes
//
//  Created by voonik on 29/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

enum NewsResult {
    case success([NewsViewModel])
    case failure(Error)
}

enum NewsError: Error {
    case invalidJSONData
}

enum WebServiceURL: String {

    case baseURL       =   "https://api.nytimes.com/svc"
    case topStories    =   "/topstories/v2/home.json"
    case searchStory   =   "/search/v2/articlesearch.json"
    case apiKey        =   "b91918aa0031431490c951ad60c8e925"
}

struct WebService {
    
    private func news(fromJSON data: Data, for webService:WebServiceURL) -> NewsResult {
        do {
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            var finalNews = [NewsViewModel]()
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any] else {
                    return .failure(NewsError.invalidJSONData)
            }
            
            switch webService {
            case .topStories:
                if let newsArray = jsonDictionary["results"] as? [[String:Any]] {
                    for newsDict in newsArray {
                        finalNews.append(NewsViewModel(NewsModel(newsDict)))
                    }
                    if finalNews.isEmpty && !newsArray.isEmpty {
                        return .failure(NewsError.invalidJSONData)
                    }
                }
            default:
                if let response = jsonDictionary["response"] as? [String:Any], let newsArray = response["docs"] as? [[String:Any]] {
                    for newsDict in newsArray {
                        finalNews.append(NewsViewModel(SearchedNewsModel(newsDict)))
                    }
                    if finalNews.isEmpty && !newsArray.isEmpty {
                        return .failure(NewsError.invalidJSONData)
                    }
                }
            }
            
            return .success(finalNews)
            
        } catch let error {
            
            return .failure(error)
        }
    }
    
    func getData(webServiceURL: WebServiceURL, baseParameters:[String:String], completionClosure: @escaping (NewsResult) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var components = URLComponents(string: "\(WebServiceURL.baseURL.rawValue)\(webServiceURL.rawValue)")!
        var queryItems = [URLQueryItem]()
        for (key, value) in baseParameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        components.queryItems = queryItems
        
        let url = components.url!
        let request = URLRequest(url: url)
        
        print(request)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let jsonData = data else { return completionClosure(.failure(error!)) }
            
            let result = self.news(fromJSON: jsonData, for: webServiceURL)
            
            DispatchQueue.main.async {
                completionClosure(result)
            }
        }
        
        task.resume()
    }
}
