//
//  NewsListCollectionViewDriver.swift
//  NYTimes
//
//  Created by voonik on 14/09/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

protocol NewsListCollectionViewDriverDelegate: class {
    func didSelectMenuItem(index: Int)
}

final class NewsListCollectionViewDriver: NSObject {
    
    fileprivate let collectionViewCellReuseIdentifier = "NewsCollectionViewCell"
    fileprivate let imageLoadQueue = OperationQueue()
    fileprivate var imageLoadOperations = [IndexPath: ImageLoader]()
    fileprivate var newsToDisplay: [NewsViewModel] = []
    
    let collectionView: UICollectionView
    weak var delegate: NewsListCollectionViewDriverDelegate?
    
    init(collectionView: UICollectionView) {
        
        self.collectionView = collectionView
        super.init()
        configure()
    }
    
    private func configure() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsetsMake(8, 0, 4, 0)
        
        // To pin the header view to the top
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    func reload(with newsToDisplay: [NewsViewModel]) {
        
        self.newsToDisplay = newsToDisplay
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension NewsListCollectionViewDriver: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return newsToDisplay.count>0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return newsToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellReuseIdentifier, for: indexPath) as? NewsCollectionViewCell {
            
            cell.configureCellWith(newsData: newsToDisplay[indexPath.item])
            
            if let imageURLString = newsToDisplay[indexPath.item].image_url {
                if let imageLoadOperation = imageLoadOperations[indexPath], let image = imageLoadOperation.image {
                    cell.snippetImageView.image = image
                } else {
                    let imageLoadOperation = ImageLoader(imageURLString: imageURLString)
                    imageLoadOperation.completionHandler = { [weak self] (image) in
                        guard let strongSelf = self else {
                            return
                        }
                        cell.snippetImageView.image = image
                        strongSelf.imageLoadOperations.removeValue(forKey: indexPath)
                    }
                    imageLoadQueue.addOperation(imageLoadOperation)
                    imageLoadOperations[indexPath] = imageLoadOperation
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageLoadOperation = imageLoadOperations[indexPath] else {
            return
        }
        imageLoadOperation.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
}


// MARK: UICollectionViewDataSourcePrefetching
extension NewsListCollectionViewDriver: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = imageLoadOperations[indexPath] {
                return
            }
            if let imageURLString = newsToDisplay[indexPath.item].image_url {
                let imageLoadOperation = ImageLoader(imageURLString: imageURLString)
                imageLoadQueue.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let imageLoadOperation = imageLoadOperations[indexPath] else {
                return
            }
            imageLoadOperation.cancel()
            imageLoadOperations.removeValue(forKey: indexPath)
        }
    }
}


// MARK: UICollectionViewDelegate
extension NewsListCollectionViewDriver: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didSelectMenuItem(index: indexPath.item)
    }
}


//MARK: - UICollectionView Flow Layout Delegate
extension NewsListCollectionViewDriver: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = UIScreen.main.bounds.width - 16
        let itemHeight: CGFloat = 267
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

