//
//  NewsCollectionViewCell.swift
//  NYTimes
//
//  Created by voonik on 28/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var publishedDateLabel: UILabel!
    @IBOutlet weak var snippetImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func configureCellWith(newsData:NewsViewModel) {
        
        publishedDateLabel.text = newsData.published_date
        titleLabel.text = newsData.title
        abstractLabel.text = newsData.abstract
    }
}
