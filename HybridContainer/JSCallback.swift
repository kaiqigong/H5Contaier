//
//  JSCallback.swift
//  HybridContainer
//
//  Created by Kaiqi Gong on 2017/9/13.
//  Copyright © 2017年 Kaiqi Gong. All rights reserved.
//

import Foundation
class JSCallback {
    var callbackId: String
    var params: String!
    init (_ callbackId: String, params: String!) {
        self.callbackId = callbackId
        self.params = params
    }
}
