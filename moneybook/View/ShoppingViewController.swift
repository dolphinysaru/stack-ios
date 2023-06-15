//
//  ShoppingViewController.swift
//  moneybook
//
//  Created by jedmin on 2023/06/15.
//

import UIKit
import WebKit

class ShoppingViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webView2: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "쇼핑"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCoupangBanner()
    }
    
    //쇼핑탭-쿠팡온리
//    <iframe src="https://ads-partners.coupang.com/widgets.html?id=670076&template=carousel&trackingCode=AF7673990&subId=&width=680&height=140&tsource=" width="680" height="140" frameborder="0" scrolling="no" referrerpolicy="unsafe-url"></iframe>
    
    //쇼핑탭-관심사기반
//    <iframe src="https://ads-partners.coupang.com/widgets.html?id=670077&template=carousel&trackingCode=AF7673990&subId=&width=680&height=140&tsource=" width="680" height="140" frameborder="0" scrolling="no" referrerpolicy="unsafe-url"></iframe>
    
    func loadCoupangBanner() {
        let file = Bundle.main.path(forResource: "coupang", ofType: "html")!
        let localHtmlString = try! String(contentsOfFile: file, encoding: .utf8)
        
        let height = webView.bounds.height - 30
        let width = UIScreen.main.bounds.width - 16
        
        let coupangIframe = String(format: "<iframe src=\"https://ads-partners.coupang.com/widgets.html?id=670076&template=carousel&trackingCode=AF7673990&subId=&width=%@&height=%@&tsource=\" width=\"%@\" height=\"%@\" frameborder=\"0\" scrolling=\"no\" referrerpolicy=\"unsafe-url\"></iframe>", "\(width)", "\(height)", "\(width)", "\(height)")
        
        let lastHtmlString = String(format: localHtmlString, coupangIframe)
                
        webView.scrollView.isScrollEnabled = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.loadHTMLString(lastHtmlString, baseURL: URL(string: "https://www.naver.com")!)
        
        let coupangIframe2 = String(format: "<iframe src=\"https://ads-partners.coupang.com/widgets.html?id=670077&template=carousel&trackingCode=AF7673990&subId=&width=%@&height=%@&tsource=\" width=\"%@\" height=\"%@\" frameborder=\"0\" scrolling=\"no\" referrerpolicy=\"unsafe-url\"></iframe>", "\(width)", "\(height)", "\(width)", "\(height)")
        
        let lastHtmlString2 = String(format: localHtmlString, coupangIframe2)
        
        webView2.scrollView.isScrollEnabled = false
        webView2.uiDelegate = self
        webView2.navigationDelegate = self
        webView2.loadHTMLString(lastHtmlString2, baseURL: URL(string: "https://www.naver.com")!)
    }
}

extension ShoppingViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("navigationAction.request \(navigationAction.request)")
        
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
        }
        return nil
    }
}
