//
//  NewsListTableViewDriver.swift
//  NYTimes
//
//  Created by voonik on 14/09/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

protocol NewsListTableViewDriverDelegate: class {
    func didSelectMenuItem(searchText: String)
}

final class NewsListTableViewDriver: NSObject {
    
    var recentSearchData = [String]()
    let tableView: UITableView
    fileprivate let tableViewCellReuseIdentifier = "RecentSearchTableViewCell"
    weak var delegate: NewsListTableViewDriverDelegate?
    
    init(tableView: UITableView) {
        
        self.tableView = tableView // This got set before calling super.init() becaue of the rule --> A Swift class must initialize its own (non-inherited) properties before it calls its superclass’s designated initializer. then you can set the inherited properties
        
        super.init() // Because of the rule --> Designated initializer must call a designated initializer from its immediate superclass.
        
        configure()
    }
    
    private func configure() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.isHidden = true
        tableView.tableFooterView = UIView.init(frame: .zero) // to remove extra seperators
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 4, 0) // to add a gap after the last cell
    }
    
    func reload(with recentSearch: [String]) {
        
        self.recentSearchData = recentSearch
        tableView.reloadData()
    }
}

// MARK: -  TableView DataSource
extension NewsListTableViewDriver: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentSearchData.count>0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellReuseIdentifier, for: indexPath) as UITableViewCell
        
        let currentRow: Int = indexPath.row
        if currentRow % 2 == 1 {
            cell.backgroundColor = UIColor.groupTableViewBackground
        }
        if indexPath.row < recentSearchData.count {
            cell.textLabel!.text = recentSearchData[indexPath.row]
        }
        cell.textLabel!.font = UIFont(name: "Helvetica Neue", size: 12.0)!
        
        return cell
    }
}


// MARK: - TableView Delegate
extension NewsListTableViewDriver: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < recentSearchData.count {
            let searchText = recentSearchData[indexPath.row]
            self.delegate?.didSelectMenuItem(searchText: searchText)
        }
    }
}
