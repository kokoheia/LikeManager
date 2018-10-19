//
//  Category.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/16.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import RealmSwift

final class Category: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var colorName: String = ""
    @objc dynamic var userID: String = ""
    
    let tweetIDs = List<String>()
    
    convenience init(title: String, colorName: String, tweetIDs: [String] = [], userID: String = "") {
        self.init()
        self.title = title
        self.colorName = colorName
        self.tweetIDs.append(objectsIn: tweetIDs)
        self.userID = userID
    }
    
    
}
