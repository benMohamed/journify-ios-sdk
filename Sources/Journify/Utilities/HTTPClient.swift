//
//  HTTPClient.swift
//  Journify-Tests
//
//  Created by Cody Garvin on 12/28/20.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

enum HTTPClientErrors: Error {
    case badSession
    case failedToOpenBatch
    case statusCode(code: Int)
}

public class HTTPClient {
    private static let defaultAPIHost = "t.journify.dev/v1"
    
    internal var session: URLSession
    private var apiHost: String
    private var apiKey: String
    
    private weak var analytics: Journify?
    
    init(analytics: Journify) {
        self.analytics = analytics
        
        self.apiKey = analytics.configuration.values.writeKey
        self.apiHost = analytics.configuration.values.apiHost
        
        self.session = Self.configuredSession(for: self.apiKey)
    }
    
    func journifyURL(for host: String, path: String) -> URL? {
        let s = "https://\(host)\(path)"
        let result = URL(string: s)
        return result
    }
    
    
    /// Starts an upload of events. Responds appropriately if successful or not. If not, lets the respondant
    /// know if the task should be retried or not based on the response.
    /// - Parameters:
    ///   - key: The write key the events are assocaited with.
    ///   - batch: The array of the events, considered a batch of events.
    ///   - completion: The closure executed when done. Passes if the task should be retried or not if failed.
    @discardableResult
    func startBatchUpload(writeKey: String, batch: URL, completion: @escaping (_ result: Result<Bool, Error>) -> Void) -> URLSessionDataTask? {
        guard let uploadURL = journifyURL(for: apiHost, path: "/b") else {
            completion(.failure(HTTPClientErrors.failedToOpenBatch))
            return nil
        }
          
        let urlRequest = configuredRequest(for: uploadURL, method: "POST")

        let dataTask = session.uploadTask(with: urlRequest, fromFile: batch) { [weak self] (data, response, error) in
            if let error = error {
                self?.analytics?.log(message: "Error uploading request \(error.localizedDescription).")
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                switch (httpResponse.statusCode) {
                case 1..<300:
                    completion(.success(true))
                    return
                case 300..<400:
                    self?.analytics?.reportInternalError(AnalyticsError.networkUnexpectedHTTPCode(httpResponse.statusCode))
                    completion(.failure(HTTPClientErrors.statusCode(code: httpResponse.statusCode)))
                case 429:
                    self?.analytics?.reportInternalError(AnalyticsError.networkServerLimited(httpResponse.statusCode))
                    completion(.failure(HTTPClientErrors.statusCode(code: httpResponse.statusCode)))
                default:
                    self?.analytics?.reportInternalError(AnalyticsError.networkServerRejected(httpResponse.statusCode))
                    completion(.failure(HTTPClientErrors.statusCode(code: httpResponse.statusCode)))
                }
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    func parseJsonData(data: Data?) -> Any? {
        guard let data = data else { return nil }
        do {
            // make sure this JSON is in the format we expect
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
    }
    
    deinit {
        // finish any tasks that may be processing
        session.finishTasksAndInvalidate()
    }
}


extension HTTPClient {
    static func authorizationHeaderForWriteKey(_ key: String) -> String {
        var returnHeader: String = ""
        let rawHeader = "\(key):"
        if let encodedRawHeader = rawHeader.data(using: .utf8) {
            returnHeader = encodedRawHeader.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        }
        return returnHeader
    }
    
    internal static func getDefaultAPIHost() -> String {
        return Self.defaultAPIHost
    }
    
    internal func configuredRequest(for url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        request.httpMethod = method
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("analytics-ios/\(Journify.version())", forHTTPHeaderField: "User-Agent")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("Basic " + HTTPClient.authorizationHeaderForWriteKey(self.apiKey), forHTTPHeaderField: "Authorization")

        if let requestFactory = analytics?.configuration.values.requestFactory {
            request = requestFactory(request)
        }
        
        return request
    }
    
    internal static func configuredSession(for writeKey: String) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 2
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        return session
    }
}
