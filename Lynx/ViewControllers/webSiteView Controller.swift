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
    
    @IBOutlet weak var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://catamaran-outremer.com/en/catamarans/outremer-4x/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

