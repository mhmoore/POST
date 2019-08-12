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
}


