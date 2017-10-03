//
//  SearchedNewsModel.swift
//  NYTimes
//
//  Created by voonik on 30/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import Foundation

struct SearchedNewsModel {
    
    let headline: [String:String]
    let pub_date: String?
    let web_url: String
    let snippet: String
    let multimedia: [Dictionary<String,Any>]
    
    init(_ newsDetails:[String:Any]) {
        
        self.headline = newsDetails["headline"] as? [String:String] ?? [String:String]()
        self.web_url = newsDetails["web_url"] as? String ?? ""
        self.snippet = newsDetails["snippet"] as? String ?? ""
        self.pub_date = newsDetails["pub_date"] as? String
        self.multimedia = newsDetails["multimedia"] as? [Dictionary<String,Any>] ?? [Dictionary<String,Any>]()
    }
}
