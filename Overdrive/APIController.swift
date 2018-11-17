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
        case failure(Error, Any?)
    }
    
    enum APIError: Error {
        case UnexpectedResponseCode,
        ResultNotSuccess,
        Unauthorized,
        InvalidSessionKey
    }
    
    struct Post: Codable {
        let userId: Int
        let id: Int
        let title: String
        let body: String
    }
    
    struct TorrentResult: Codable {
        let addedDate: Int
        let name: String
        let status: Int
        let downloadDir: String
    }
    
    struct TorrentListResult: Codable {
        let torrents: [TorrentResult]
    }
    
    struct GetTorrentResult: Codable {
        let arguments: TorrentListResult
        let result: String
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
        request.addValue(server.headerKey, forHTTPHeaderField: "X-Transmission-Session-Id")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // prepare json data
        let json: [String: Any] = [
            "arguments": [
                "fields": [ "addedDate", "name", "status" ],
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
                    completion?(.failure(error, nil))
                } else if httpResponse.statusCode == 401 {
                    completion?(.failure(APIError.Unauthorized, nil))
                } else if httpResponse.statusCode == 409 {
                    let sessionKey = httpResponse.allHeaderFields["X-Transmission-Session-Id"]
                    completion?(.failure(APIError.InvalidSessionKey, sessionKey))
                } else if let jsonResponse = responseData {
                    // Now we have jsonData, Data representation of the JSON returned to us
                    // from our URLRequest...
                    
                    // Create an instance of JSONDecoder to decode the JSON data to our
                    // Codable struct
                    let decoder = JSONDecoder()
                    
                    do {
                        // We would use Post.self for JSON representing a single Post
                        // object, and [Post].self for JSON representing an array of
                        // Post objects
                        let torrentResult = try decoder.decode(GetTorrentResult.self, from: jsonResponse)
                        if torrentResult.result != "success" {
                            completion?(.failure(APIError.ResultNotSuccess, nil))
                        }
                        completion?(.success(torrentResultToTorrent(torrentResults: torrentResult.arguments.torrents)))
                    } catch {
                        completion?(.failure(error, nil))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error, nil))
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
            guard let torrent = Torrent(name: torrentResult.name, path: path, addedDate: addedDate, status: torrentResult.status) else {
                fatalError("Could not cast torrent to Torrent")
            }
            torrents.append(torrent)
        }
        return torrents
    }
}
