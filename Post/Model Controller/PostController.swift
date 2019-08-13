//
//  PostController.swift
//  Post
//
//  Created by Michael Moore on 8/12/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController {
    
    var posts: [Post] = []
    
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    func fetchPosts(completion: @escaping() -> Void) {
        
        guard let unwrappedURL = baseURL else {return}
        let getterEndpoint = unwrappedURL.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: getterEndpoint)
        urlRequest.httpMethod = "GET"
        urlRequest.httpBody = nil
        
        let _ = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("Error fetching data. \(error): \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data else { return }
            
            do {
                let postsDictionary = try JSONDecoder().decode([String : Post].self, from: data)
                var posts = postsDictionary.compactMap({$0.value})
                posts.sort(by: { ($0.timestamp > $1.timestamp) })
                self.posts = posts
                completion()
                return
            } catch {
                print("There was an error decoding. \(error): \(error.localizedDescription)")
                completion()
                return
            }
        }.resume()
    }


    func addNewPostWith(username: String, text: String, completion: @escaping() -> Void) {
        let post = Post(text: text, username: username, timestamp: Date().timeIntervalSince1970)  // timestamp?
        
        var postData: Data
        let jsonEncoder = JSONEncoder()
        
        do {
            postData = try jsonEncoder.encode(post)
        } catch {
            print("There was an error encoding. \(error): \(error.localizedDescription)")
            return
        }
        
        guard let unwrappedURL = baseURL else { return }
        
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        
        var urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postData
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("There was and error posting data. \(error): \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data else { return }
            let dataResponseString = String(data: data, encoding: .utf8)
            self.posts.append(post)
            self.fetchPosts(completion: {
                completion()
            })
        }.resume()
    }

}


