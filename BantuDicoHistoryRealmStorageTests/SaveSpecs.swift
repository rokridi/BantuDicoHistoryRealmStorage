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
    
        AsyncDefaults.Timeout = 10
        AsyncDefaults.PollInterval = 0.1
                
        describe("Save") {
            
            var storage: BantuDicoHistoryRealmStorage!
            var testRealm: Realm!
            
            beforeEach {
                storage = BantuDicoHistoryRealmStorage(storeName: self.name, storeType: .inMemory)
                testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: self.name))
            }
            
            afterEach {
                do {
                    try testRealm.write {
                        testRealm.deleteAll()
                    }
                } catch let error {
                    print(error)
                }
            }
            
            context("Save translation", {
                it("should save translation with success", closure: {
                    /*
                    waitUntil(timeout: 10, action: { done in
                        storage.saveTranslation(Translations.saveTranslation, completion: { success, error in
                            expect(success).to(beTrue())
                            expect(error).to(beNil())
                            
                            storage.fetchTranslation(word: Translations.saveTranslation.word, language: Translations.saveTranslation.language, translationLanguage: Translations.saveTranslation.translationLanguage, completion: { translation, error in

                                expect(translation).toNot(beNil())
                                expect(error).to(beNil())
                                
                                done()
                            })
                        })
                    })
 */
                    
                    storage.saveTranslation(Translations.saveTranslation, completion: { success, error in
                        expect(success).toEventually(beTrue())
                        expect(error).toEventually(beNil())
                        
                        storage.fetchTranslation(word: Translations.saveTranslation.word, language: Translations.saveTranslation.language, translationLanguage: Translations.saveTranslation.translationLanguage, completion: { translation, error in
                            
                            expect(translation).toEventuallyNot(beNil())
                            expect(error).toEventually(beNil())
                            expect(translation?.word).toEventually(equal(Translations.saveTranslation.word))
                        })
                    })
                })
            })
        }
    }
}
