//
//  menu.swift
//  Lynx
//
//  Created by Pietro on 10/05/22.
//

import Foundation
import UIKit
import WebKit

class websiteViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        let url = URL(string: "https://catamaran-outremer.com/en/catamarans/outremer-4x/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
}

