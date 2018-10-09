//
//  UserTweets.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/10/08.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import Foundation

//This is a dummy class for storing tweetIDs of each user
class UserTweets {
    var tweetIDs = [String]()
    
    init(tweetIDs: [String]) {
        self.tweetIDs = tweetIDs
    }
}
