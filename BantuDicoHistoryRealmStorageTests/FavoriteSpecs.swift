//
//  FavoriteSpecs.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 19/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RealmSwift
@testable import BantuDicoHistoryRealmStorage

class FavoriteSpecs: QuickSpec {
    
    override func spec() {
        
        let storage = BantuDicoHistoryRealmStorage(storeName: self.name, storeType: .inMemory)
        
        afterEach {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = self.name
            let testRealm = try! Realm(configuration: config)
            try! testRealm.write {
                testRealm.deleteAll()
            }
        }
        
        describe("Favorites") {
            
            context("add to favorites", {
                it("should add translation to favorites", closure: {
                    waitUntil(timeout: 3, action: { done in
                        storage.addTranslationToFavorites(Translations.addFavoriteTranslation, completion: { success, error in
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            done()
                        })
                    })
                })
            })
            
            context("remove from favorites", {
                
                it("should be remove translation from favorites", closure: {
                    waitUntil(timeout: 3, action: { done in
                        storage.addTranslationToFavorites(Translations.removeFavoriteTranslation, completion: { success, error in
                            
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            
                            storage.removeTranslationFromFavorites(Translations.removeFavoriteTranslation, completion: { success, error in
                                expect(success).to(equal(true))
                                expect(error).to(beNil())
                                done()
                            })
                        })
                    })
                })
            })
        }
    }
}
