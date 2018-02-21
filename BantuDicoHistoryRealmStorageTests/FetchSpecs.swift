//
//  FetchSpec.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 20/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import BantuDicoHistoryRealmStorage

class FetchSpecs: QuickSpec {
    
    let storage = BantuDicoHistoryRealmStorage(storeName: "BantuDicoHistoryRealmStorage", storeType: .inMemory)
    
    override func spec() {
        
        describe("Favorites") {
            
            context("add to favorites", {
                
                it("should add translation to favorites", closure: {
                    
                    
                })
            })
            
            context("remove from favorites", {
                
                it("should be remove translation from favorites", closure: {
                    
                    
                })
            })
        }
    }
}
