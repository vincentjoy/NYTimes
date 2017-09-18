//
//  NewsContainerViewController.swift
//  NYTimes
//
//  Created by voonik on 31/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import UIKit

class NewsContainerViewController: UIViewController, UIWebViewDelegate, HandleWebserviceProtocol {
    
    @IBOutlet weak var webView: UIWebView!
    
    var pageIndex = 0
    var pageURL: String!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        webView.delegate = self
        UIWebView.loadRequest(webView)(URLRequest(url: URL(string: pageURL)!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        guard self.connectedToNetwork() else {
            self.handleError(title: "No Internet Connection", message: "Please check your connection settings and try again")
            return
        }
    }
    
    // MARK: WebView Delegate Methods
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
