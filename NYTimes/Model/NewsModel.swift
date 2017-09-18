//
//  NewsModel.swift
//  NYTimes
//
//  Created by voonik on 29/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import Foundation

struct NewsModel {
    
    let title: String
    let published_date: String?
    let url: String
    let abstract: String
    let multimedia: [Dictionary<String,Any>]
    
    init(_ newsDetails:[String:Any]) {
        
        self.title = newsDetails["title"] as? String ?? ""
        self.url = newsDetails["url"] as? String ?? ""
        self.abstract = newsDetails["abstract"] as? String ?? ""
        self.published_date = newsDetails["published_date"] as? String
        self.multimedia = newsDetails["multimedia"] as? [Dictionary<String,Any>] ?? [Dictionary<String,Any>]()
    }
}
