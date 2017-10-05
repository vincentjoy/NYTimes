//
//  NetworkEngine.swift
//  NYTimes
//
//  Created by voonik on 05/10/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import Foundation

class NetworkEngine {
    
    static let sharedEngine = NetworkEngine()
    private init() {}
    
    func parseData(fromWebCall jsonData: Data, for webService:WebServiceURL) -> NewsResult {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
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
}
