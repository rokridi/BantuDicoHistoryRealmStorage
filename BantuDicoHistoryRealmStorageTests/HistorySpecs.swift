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
import RealmSwift
@testable import BantuDicoHistoryRealmStorage

class HistorySpecs: QuickSpec {
    
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
        
        describe("History") {
            
            context("Fetch all history", {
                it("should return one element", closure: {
                    waitUntil(timeout: 3, action: { done in
                        storage.addTranslationToFavorites(Translations.fetchTranslation, completion: { success, error in
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            
                            storage.fetchAllTranslations(completion: { translations, error in
                                expect(error).to(beNil())
                                expect(translations).toNot(beNil())
                                
                                if let translations = translations {
                                    
                                    expect(translations.count).to(equal(1))
                                    
                                    if let element = translations.first {
                                        expect(element.identifier).to(match(Translations.fetchTranslation.identifier))
                                    }
                                }
                                done()
                            })
                        })
                    })
                })
            })
        }
    }
}
