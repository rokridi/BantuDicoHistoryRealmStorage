//
//  SaveSpec.swift
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

class SaveSpecs: QuickSpec {
    
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
        
        describe("Save") {
            
            context("Save translation", {
                it("should save translation with success", closure: {
                    waitUntil(timeout: 3, action: { done in
                        storage.saveTranslation(Translations.saveTranslation, completion: { success, error in
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            done()
                        })
                    })
                })
            })
        }
    }
}
