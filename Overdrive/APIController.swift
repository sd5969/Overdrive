//
//  ApiController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/15/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import Foundation
extension String: Error {}

class APIController {
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    enum APIError: LocalizedError {
        case UnexpectedResponseCode,
        ResultNotSuccess,
        Unauthorized,
        InvalidSessionKey
        
        public var errorDescription: String? {
            switch self {
            case .UnexpectedResponseCode:
                return NSLocalizedString("API response code does not match expectation", comment: "")
            case .ResultNotSuccess:
                return NSLocalizedString("API returned unsuccessful response", comment: "")
            case .Unauthorized:
                return NSLocalizedString("Authentication unsuccessful", comment: "")
            case .InvalidSessionKey:
                return NSLocalizedString("API session key invalid", comment: "")
            }
        }
    }
    
    struct TorrentResult: Codable {
        let addedDate: Int
        let name: String
        let status: Int
        let downloadDir: String
        let id: Int
    }
    
    struct TorrentListResult: Codable {
        let torrents: [TorrentResult]
    }
    
    struct GetTorrentResult: Codable {
        let arguments: TorrentListResult
        let result: String
    }
    
    static func createCredentials(server: Server) -> String {
        if server.username.isEmpty {
            return ""
        }
        let username = server.username
        let password = server.password
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        return loginData.base64EncodedString()
    }
    
    static func getSessionId(for server: Server, completion: ((Result<String>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = server.hostname
        urlComponents.port = server.port
        urlComponents.path = server.rootDirectory
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(server.sessionKey, forHTTPHeaderField: "X-Transmission-Session-Id")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let creds = createCredentials(server: server)
        if !creds.isEmpty {
            request.addValue("Basic \(creds)", forHTTPHeaderField: "Authorization")
        }
        
        // prepare json data
        let json: [String: Any] = [
            "arguments": [
                "fields": [ "version" ],
            ],
            "method": "session-get"
        ]
        
        var jsonData: Data
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json)
        } catch {
            fatalError("Unable to create JSON body payload")
        }
        
        request.httpBody = jsonData
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    fatalError("Could not cast response to HTTP response")
                }
                if let error = responseError {
                    completion?(.failure(error))
                } else if httpResponse.statusCode == 401 {
                    completion?(.failure(APIError.Unauthorized))
                } else if httpResponse.statusCode == 409 {
                    let sessionKey = httpResponse.allHeaderFields["X-Transmission-Session-Id"] as! String
                    completion?(.success(sessionKey))
                } else if httpResponse.statusCode == 200 {
                    completion?(.success("")) // using empty to indicate no need to change sessionKey
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    static func getTorrents(for server: Server, completion: ((Result<[Torrent]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = server.hostname
        urlComponents.port = server.port
        urlComponents.path = server.rootDirectory
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(server.sessionKey, forHTTPHeaderField: "X-Transmission-Session-Id")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let creds = createCredentials(server: server)
        if !creds.isEmpty {
            request.addValue("Basic \(creds)", forHTTPHeaderField: "Authorization")
        }
        
        // prepare json data
        let json: [String: Any] = [
            "arguments": [
                "fields": [ "addedDate", "name", "status", "downloadDir", "id" ],
            ],
           "method": "torrent-get"
        ]
        
        var jsonData: Data
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: json)
        } catch {
            fatalError("Unable to create JSON body payload")
        }
        
        request.httpBody = jsonData
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    fatalError("Could not cast response to HTTP response")
                }
                if let error = responseError {
                    completion?(.failure(error))
                } else if httpResponse.statusCode == 401 {
                    completion?(.failure(APIError.Unauthorized))
                } else if httpResponse.statusCode == 409 {
                    completion?(.failure(APIError.InvalidSessionKey))
                } else if let jsonResponse = responseData {
                    let decoder = JSONDecoder()
                    
                    do {
                        let torrentResult = try decoder.decode(GetTorrentResult.self, from: jsonResponse)
                        if torrentResult.result != "success" {
                            completion?(.failure(APIError.ResultNotSuccess))
                        }
                        completion?(.success(torrentResultToTorrent(torrentResults: torrentResult.arguments.torrents)))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    static func torrentResultToTorrent(torrentResults: [TorrentResult]) -> [Torrent] {
        var torrents = [Torrent]()
        for torrentResult in torrentResults {
            guard let path = Path(path: torrentResult.downloadDir) else {
                fatalError("Could not cast path to Path")
            }
            guard let timeInterval = TimeInterval(exactly: torrentResult.addedDate) else {
                fatalError("Could not cast addedDate to TimeInterval")
            }
            let addedDate = Date(timeIntervalSince1970: timeInterval)
            guard let torrent = Torrent(name: torrentResult.name, path: path, addedDate: addedDate, status: torrentResult.status, id: torrentResult.id) else {
                fatalError("Could not cast torrent to Torrent")
            }
            torrents.append(torrent)
        }
        return torrents
    }
}
