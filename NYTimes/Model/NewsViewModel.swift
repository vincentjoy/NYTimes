//
//  NewsViewModel.swift
//  NYTimes
//
//  Created by voonik on 29/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import Foundation

enum Format: String {
    case MEDIUM = "mediumThreeByTwo210"
    case WIDE = "wide"
}

struct NewsViewModel: Comparable {
    
    let title: String
    let newsURL: String
    let abstract: String
    var published_date: String?
    var image_url: String?
    
    init(_ newsModel:NewsModel) {
        
        self.title = newsModel.title.uppercased()
        self.newsURL = newsModel.url
        self.abstract = newsModel.abstract
        
        if let dateString = newsModel.published_date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'-'HH:mm"
            if let date = formatter.date(from: dateString) {
                /* Date to String */
                let newDateFormat = DateFormatter()
                newDateFormat.dateFormat = "EEEE, dd MMMM yyyy"
                self.published_date = (newDateFormat.string(from: date)).uppercased()
            }
        }
        
        let multimedia = newsModel.multimedia
        if multimedia.count>0 {
            for dict in multimedia {
                if let imageFormat = dict["format"] as? String, imageFormat==Format.MEDIUM.rawValue {
                    self.image_url = dict["url"] as? String
                }
            }
        }
    }
    
    init(_ searchedNewsModel:SearchedNewsModel) {
        
        self.newsURL = searchedNewsModel.web_url
        self.abstract = searchedNewsModel.snippet
        
        if let headline = searchedNewsModel.headline["main"] {
            self.title = headline.uppercased()
        } else if let headline = searchedNewsModel.headline["print_headline"] {
            self.title = headline.uppercased()
        } else {
            self.title = ""
        }
        
        if let dateString = searchedNewsModel.pub_date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: dateString) {
                /* Date to String */
                let newDateFormat = DateFormatter()
                newDateFormat.dateFormat = "EEEE, dd MMMM yyyy"
                self.published_date = (newDateFormat.string(from: date)).uppercased()
            }
        }
        
        let multimedia = searchedNewsModel.multimedia
        if multimedia.count>0 {
            for dict in multimedia {
                if let imageFormat = dict["subtype"] as? String, imageFormat==Format.WIDE.rawValue, let url = dict["url"] as? String {
                    self.image_url = "https://static01.nyt.com/\(url)"
                }
            }
        }
    }
}

func < (lhs: NewsViewModel, rhs: NewsViewModel) -> Bool {
    return lhs.title < rhs.title
}

func > (lhs: NewsViewModel, rhs: NewsViewModel) -> Bool {
    return lhs.title > rhs.title
}

func == (lhs: NewsViewModel, rhs: NewsViewModel) -> Bool {
    return lhs.title == rhs.title
}

