//
//  User.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/30.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {

    @objc dynamic var isCurrentUser = false
    @objc dynamic var userID: String = ""
    
    var userName: String?
    var profileImageUrlString: String?
    
    //init for registering realm
    convenience init(userID: String) {
        self.init()
        self.userID = userID
    }
    
    //init for registering cache
    convenience init(userID: String, userName: String?, profileImageUrlString: String) {
        self.init()
        self.userID = userID
        self.userName = userName
        self.profileImageUrlString = profileImageUrlString
    }
    
    override static func ignoredProperties() -> [String] {
        return ["accountName", "profileImageUrlString"]
    }
   
}
