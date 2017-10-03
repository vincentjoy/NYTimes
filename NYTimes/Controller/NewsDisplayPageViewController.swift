//
//  NewsDisplayPageViewController.swift
//  NYTimes
//
//  Created by voonik on 31/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

class NewsDisplayPageViewController: UIPageViewController {

    var currentIndex: Int?
    var newsToDisplay: [NewsViewModel]?
    private var newsContainertViewController = NewsContainerViewController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        newsContainertViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewsContainerVC") as! NewsContainerViewController
        
        self.navigationController?.navigationBar.isHidden = false
        self.dataSource = self
        
        self.setViewControllers([getViewControllerAtIndex(index: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.setViewControllers([getViewControllerAtIndex(index: currentIndex ?? 0)], direction: .forward, animated: true, completion: nil)
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> NewsContainerViewController {
        
        newsContainertViewController.pageURL = newsToDisplay?[index].newsURL
        newsContainertViewController.pageIndex = index
        return newsContainertViewController
    }
}

extension NewsDisplayPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let pageContent = viewController as! NewsContainerViewController
        var index = pageContent.pageIndex
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        index -= 1
        return getViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let pageContent = viewController as! NewsContainerViewController
        var index = pageContent.pageIndex
        if (index == NSNotFound) {
            return nil
        }
        index += 1
        if (index == newsToDisplay?.count) {
            return nil
        }
        return getViewControllerAtIndex(index: index)
    }
}
