//
//  Post.swift
//  Post
//
//  Created by Michael Moore on 8/12/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    var text: String
    var username: String
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    
// the API will return a duplicate of the last post.  We create this computed property to remove this bug and then called it in our fetchPosts 
    var queryTimestamp: TimeInterval {
        return timestamp + 0.00001
    }
}
