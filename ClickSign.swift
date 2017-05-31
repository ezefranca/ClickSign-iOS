//
//  ClickSign.swift
//  ClickSign-iOS
//
//  Created by Ezequiel França on 30/05/17.
//  Copyright © 2017 Ezequiel França. All rights reserved.
//

import WebKit
import Foundation
import UIKit

@objc protocol ClickSignDelegate : class {
    
    @objc optional func clickSign(_ clickSign: ClickSign, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    @objc optional func clickSignContentProcessDidTerminate(_ clickSign: ClickSign)
    @objc optional func clickSign(_ clickSign: ClickSign, didCommit navigation: WKNavigation!)
    @objc optional func clickSign(_ clickSign: ClickSign, didFinish navigation: WKNavigation!)
    @objc optional func clickSign(_ clickSign: ClickSign, didStartProvisionalNavigation navigation: WKNavigation!)
    @objc optional func clickSign(_ clickSign: ClickSign, didFail navigation: WKNavigation!, withError error: Error)
    @objc optional func clickSign(_ clickSign: ClickSign, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    @objc optional func clickSign(_ clickSign: ClickSign, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    @objc optional func clickSign(_ clickSign: ClickSign, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
    @objc optional func clickSign(_ clickSign: ClickSign, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    @objc optional func clickSign(_ clickSign: ClickSign, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void)
    @objc optional func clickSign(_ clickSign: ClickSign, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void)
    @objc optional func clickSign(_ clickSign: ClickSign, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void)
    @objc optional func clickSignDidClose(_ clickSign: ClickSign)
}

class ClickSign : UIView {
    
    fileprivate var controller:UIViewController!
    var webView: WKWebView!
    var progressView: UIProgressView!
    var title:String!
    
    init(frame: CGRect, controller: UIViewController) {
        super.init(frame: frame)
        self.controller = controller
        self.setupWebView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupWebView() {
        
        //self.edgesForExtendedLayout = .None
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = WKPreferences()
        configuration.preferences.minimumFontSize = 10
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.userContentController = WKUserContentController()
        
        let script = WKUserScript(source: "function showAlert() { alert('Alerta: Javascript dentro do Swift'); }",
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)
        
        // window.webkit.messageHandlers.AppModel.postMessage({body: 'body'})
        configuration.userContentController.add(self, name: "AppModel")
        
        self.webView = WKWebView(frame: self.bounds, configuration: configuration)
        
        let url = Bundle.main.url(forResource: "clicksign", withExtension: "html")
        self.webView.load(URLRequest(url: url!))
        self.addSubview(self.webView);
        
        self.webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView.frame.size.width = self.frame.size.width
        self.progressView.backgroundColor = UIColor.red
        self.addSubview(self.progressView)
    }
    
    
    func previousPage() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    func nextPage() {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
}

extension ClickSign : WKScriptMessageHandler {
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        if message.name == "AppModel" {
            print("message name is AppModel")
        }
    }
}

extension ClickSign {
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loading" {
            print("loading")
        } else if keyPath == "title" {
            self.title = self.webView.title
        } else if keyPath == "estimatedProgress" {
            print(webView.estimatedProgress)
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        
        if !webView.isLoading {
            let js = "callJsAlert()";
            self.webView.evaluateJavaScript(js) { (_, _) -> Void in
                print("call js alert")
            }
            
            UIView.animate(withDuration: 0.55, animations: { () -> Void in
                self.progressView.alpha = 0.0;
            })
        }
        
    }
}

extension ClickSign : WKUIDelegate {
    
    // MARK: - WKUIDelegate
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "Chamando Alert através do Javascript", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            completionHandler()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
            completionHandler()
        }))
        
        self.controller.present(alert, animated: true, completion: nil)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
    }

    func webViewDidClose(_ webView: WKWebView) {
        print(#function)
    }
    
}

extension ClickSign : WKNavigationDelegate {
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
        
        let hostname = navigationAction.request.url?.host?.lowercased()
        
        print(hostname ?? "host nulo")
        if navigationAction.navigationType == .linkActivated && !hostname!.contains(".google.com") {
            UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: { (complete) in
                print(complete)
            })
            decisionHandler(.cancel)
        } else {
            self.progressView.alpha = 1.0
            
            decisionHandler(.allow)
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print(#function)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        completionHandler(.performDefaultHandling, nil)
    }
    
    
}
