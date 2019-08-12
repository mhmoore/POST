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
}
