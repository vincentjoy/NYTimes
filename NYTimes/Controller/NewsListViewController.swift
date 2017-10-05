//
//  NewsListViewController.swift
//  NYTimes
//
//  Created by voonik on 29/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController, HandleWebserviceProtocol {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var webService = WebService()
    fileprivate var collectionViewDriver: NewsListCollectionViewDriver!
    fileprivate var newsToDisplay: [NewsViewModel] = []
    fileprivate var page = 0
    fileprivate var paginationFlag = false
    fileprivate var searchFlag = false
    fileprivate var recentSearchTableView: UITableView?
    fileprivate var recentSearchData: [String] = []
    fileprivate var tableViewDriver: NewsListTableViewDriver!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionViewDriver = NewsListCollectionViewDriver(collectionView: collectionView!)
        collectionViewDriver.delegate = self
        
        self.topStoryWebService()
        setupSearchSuggestion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func topStoryWebService() {
        let webServiceURL = WebServiceURL.topStories
        let baseParameters = [
            "api_key": WebServiceURL.apiKey.rawValue,
            "page": "\(page)"
        ]
        getNewsFor(webServiceURL: webServiceURL, baseParameters: baseParameters)
    }
    
    func searchWebService(searchText: String) {
        let webServiceURL = WebServiceURL.searchStory
        let baseParameters = [
            "api_key": WebServiceURL.apiKey.rawValue,
            "q": searchText,
            "page": "\(page)"
        ]
        getNewsFor(webServiceURL: webServiceURL, baseParameters: baseParameters)
    }
    
    func getNewsFor(webServiceURL:WebServiceURL, baseParameters:[String:String]) {
        
        guard self.connectedToNetwork() else {
            self.handleError(title: "No Internet Connection", message: "Please check your connection settings and try again")
            return
        }
        
        webService.getData(webServiceURL: webServiceURL, baseParameters:baseParameters) { (NewsResult) in
            
            switch NewsResult {
            case let .success(news):
                
                guard let news = news as? [NewsViewModel], news.count>0 else {
                    self.handleError(title: "Sorry", message: "No results found")
                    return
                }
                if self.newsToDisplay.containsSameElements(as: news) { // To stop further pagination once all the news are loaded
                    self.paginationFlag = false
                } else {
                    self.paginationFlag = true
                    self.page += 1
                    self.newsToDisplay = news
                    self.collectionViewDriver.reload(with: news)
                    /* Scroll the collectionview to the top */
                    if self.page==1 {
                        let firstItem = IndexPath(row: 0, section: 0)
                        self.collectionView.scrollToItem(at: firstItem, at: .top, animated: false)
                    }
                }
            case let .failure(error):
                print("Error fetching news: \(error)")
            }
        }
    }
    
    func setupSearchSuggestion() {
        
        self.view.layoutIfNeeded()
        
        let yPosition:CGFloat = searchBar.frame.size.height + 22
        let width:CGFloat = self.view.bounds.size.width
        
        recentSearchTableView = UITableView.init(frame: CGRect(x: 0, y: yPosition, width: width, height: 254), style: .plain)
        tableViewDriver = NewsListTableViewDriver(tableView: recentSearchTableView!)
        tableViewDriver.delegate = self
        
        /* Adding shadow to the drop down */
        let shadowPath = UIBezierPath(rect: (recentSearchTableView?.bounds)!)
        recentSearchTableView?.layer.masksToBounds = false
        recentSearchTableView?.layer.shadowColor = UIColor.black.cgColor
        recentSearchTableView?.layer.shadowOffset = CGSize(width: 0, height: 1)
        recentSearchTableView?.layer.shadowOpacity = 0.5
        recentSearchTableView?.layer.shadowPath = shadowPath.cgPath
        
        self.view.addSubview(recentSearchTableView!)
    }
}


//MARK: - Search Delegate
extension NewsListViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        if let data = RecentSearchHandler.shared.getRecentSearchData() {
            recentSearchData = data.reversed()
            recentSearchTableView?.isHidden = false
            self.tableViewDriver.reload(with: self.recentSearchData)
        }
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchBar.resignFirstResponder()
            RecentSearchHandler.shared.saveRecentSearchData(searchedText: searchText)
            recentSearchTableView?.isHidden = true
            self.searchWebService(searchText: searchText)
            self.searchFlag = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recentSearchTableView?.isHidden = true
        searchBar.resignFirstResponder()
        if (searchBar.text?.isEmpty ?? false) {
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        page = 0
        if(searchText.isEmpty){
            self.topStoryWebService()
            self.searchFlag = false
        }
    }
}


// MARK: - UIScrollViewDelegate
extension NewsListViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if paginationFlag && !searchFlag {
            
            let bottomEdge: CGFloat = self.collectionView.contentOffset.y + self.collectionView.frame.size.height
            let contentSize = self.collectionView.contentSize.height
            if bottomEdge >= contentSize {
                paginationFlag = false
                self.topStoryWebService()
            }
        }
    }
}


// MARK: - NewsListCollectionViewDriver Delegate
extension NewsListViewController: NewsListCollectionViewDriverDelegate {
    
    func didSelectMenuItem(index: Int) {
        
        if let newsDisplayVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsDisplayPageVC") as? NewsDisplayPageViewController {
            
            newsDisplayVC.currentIndex = index
            newsDisplayVC.newsToDisplay = newsToDisplay
            self.navigationController?.pushViewController(newsDisplayVC, animated: true)
        }
    }
}


// MARK: - NewsListTableViewDriver Delegate
extension NewsListViewController: NewsListTableViewDriverDelegate {
    
    func didSelectMenuItem(searchText: String) {
        
        self.searchWebService(searchText: searchText)
        searchBar.resignFirstResponder()
        searchBar.text = searchText
        self.recentSearchTableView?.isHidden = true
    }
}
