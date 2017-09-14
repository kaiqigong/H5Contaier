//
//  CacheStore.swift
//  HybridContainer
//
//  Created by Kaiqi Gong on 2017/9/14.
//  Copyright © 2017年 Kaiqi Gong. All rights reserved.
//
import SwiftStore
import Foundation

class CacheStore : SwiftStore {
    /* Shared Instance */
    static let store = CacheStore()
    
    init() {
        super.init(storeName: "db")
    }
}
