//
//  WebService.swift
//  NYTimes
//
//  Created by voonik on 29/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

enum NewsResult {
    case success([Any])
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
            
            let result = NetworkEngine.sharedEngine.parseData(fromWebCall: jsonData, for: webServiceURL)
            
            DispatchQueue.main.async {
                completionClosure(result)
            }
        }
        
        task.resume()
    }
}
