//
//  LocalCacheProtocol.swift
//  HybridContainer
//
//  Created by Kaiqi Gong on 2017/9/13.
//  Copyright © 2017年 Kaiqi Gong. All rights reserved.
//
import UIKit
import CoreData
import Foundation

class LocalCacheProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    private var dataTask: URLSessionDataTask?
    private var urlResponse: URLResponse?
    private var receivedData: NSMutableData?
    
    // MARK: URLProtocol
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        var request = self.request
        
        // check cache
        let urlString = request.url?.absoluteString
        let cached = CacheStore.store[urlString!]
        if cached != nil {
            if let data = cached?.data(using: .utf8, allowLossyConversion: true) {
                let cachedResponse = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! NSDictionary
                if cachedResponse != nil {
                    let response = URLResponse.init(url: cachedResponse?.value(forKey: "url") as! URL, mimeType: cachedResponse?.value(forKey: "mimeType") as? String, expectedContentLength: (cachedResponse?.value(forKey: "data") as! String).lengthOfBytes(using: String.Encoding.utf8), textEncodingName: cachedResponse?.value(forKey: "encoding") as? String)
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
                    self.client?.urlProtocol(self, didLoad: cachedResponse?.value(forKey: "data") as! Data)
                    self.client?.urlProtocolDidFinishLoading(self)
                    print("Cached URL: \(String(describing: urlString))\n\n")
                    return
                }
            }
        }
        
        
        // Set a awt-token
        if request.url?.host?.range(of: ".shunshunliuxue.com") != nil {
            let jwtToken: String = "jwt-token=I%2BHEG2SqbIKA8XoJsz0aWq5RmHPkm2ToivO7TiCNXzNBXStFRfZSYWxgNZV2eGGYO5IC5F2M%2B1kk%2Fwm4W%2BBL9W8DmsuIiUbJMhPJfB9y59bElX23jrkcDq1EyE4KqvML0P9t%2BAVXYCQNMCHhb0crp97EIc2zgGdPybvHy0NRJUZ3%2Bmalq%2BFLmy9B4QllhQtfj1OBQggkzu4fHEbLBcfsQNFAMcEMqjJooMjMLSSJyuPDXTVUXuC0dhgW3iWFz5yb%2ByevFycDLXWH%2FtQJWULxBtov3x0K2Nbm%2BL5SWSD%2BWCBN9QbEGKPD4hcDYPDm%2BLAwuS4b63o5EzAliWvI7yER%2Bg%3D%3D; ssa.sid=s%3Ad-MJerFXw6SVMNds_c1fA14PyxrwWs2X.kpMHw7Zu0DWgCqHocQKeRI9CF2jjaNGAm31kkhXDhqE; gr_session_id_bedf9751acb060e9=c1bcebcf-66de-4cd1-be74-d5ee9343e6f7;"
            let originCookie: String = request.value(forHTTPHeaderField: "Cookie") ?? ""
            if originCookie.range(of: "jwt-token=") == nil {
                let newCookie: String = jwtToken + originCookie
                request.setValue(newCookie, forHTTPHeaderField: "Cookie")
            }
        }
        
        // Set the CustomKey property to stop reloading NSURLProtocol
        
        
        var defaultConfigObj: URLSessionConfiguration;
        
        defaultConfigObj = URLSessionConfiguration.default
        
        let defaultSession = URLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)
        
        
        self.dataTask = defaultSession.dataTask(with: request)
        self.dataTask!.resume()
    }
    
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask       = nil
        self.receivedData   = nil
        self.urlResponse    = nil
    }
    
    // MARK: URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        self.urlResponse = response
        self.receivedData = NSMutableData()
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
        
        self.receivedData?.append(data)
    }
    
    // MARK: NSURLSessionTask
    // Handle Redirects
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        
        //    if let httpResponse = response as? NSHTTPURLResponse {
        //      client?.URLProtocol(self, wasRedirectedToRequest: request, redirectResponse: httpResponse)
        //    }
        completionHandler(nil)
    }
    
    // MARK: NSURLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            self.client?.urlProtocol(self, didFailWithError: error!)
            NSLog("* Error url: \(String(describing: self.request.url?.absoluteString))\n* Details: \(String(describing: error))")
        } else {
            saveCachedResponse()
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    /**
     Do whatever with the data here
     */
    func saveCachedResponse () {
//        let appDelegate: AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        let timeStamp = NSDate()
        let urlString = self.request.url?.absoluteString
        let dataString = NSString(data: self.receivedData! as Data, encoding: String.Encoding.utf8.rawValue) as NSString?
        if (dataString != nil) {
            let cachedResponse = NSDictionary.init()
            cachedResponse.setValue(urlString, forKey: "url")
            cachedResponse.setValue(dataString, forKey: "data")
            cachedResponse.setValue(self.urlResponse?.mimeType, forKey: "mimeType")
            cachedResponse.setValue(timeStamp, forKey: "timestamp")
            cachedResponse.setValue(self.urlResponse?.textEncodingName, forKey: "encoding")
            let data = try? JSONSerialization.data(withJSONObject: cachedResponse, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            CacheStore.store[urlString!] = String(data:data!, encoding: String.Encoding.utf8)
        }
        
        print("TimeStamp:\(timeStamp)\nURL: \(String(describing: urlString))\n\nDATA:\(String(describing: dataString))\n\n")
    }
    
}
