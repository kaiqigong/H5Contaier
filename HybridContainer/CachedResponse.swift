//
//  CachedResponse.swift
//  HybridContainer
//
//  Created by Kaiqi Gong on 2017/9/14.
//  Copyright © 2017年 Kaiqi Gong. All rights reserved.
//

import Foundation

class CachedResponse {
    var url: String
    var data: String!
    var mineType: String!
    var timestamp: Date!
    var encoding: UInt!

    init (_ url: String, data: String!, mineType: String!, timestamp: Date!, encoding: UInt!) {
        self.url = url
        self.data = data
        self.mineType = mineType
        self.timestamp = timestamp
        self.encoding = encoding
    }
}
