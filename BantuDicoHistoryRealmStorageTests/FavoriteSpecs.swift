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
        
        AsyncDefaults.Timeout = 10
        AsyncDefaults.PollInterval = 0.1
        
        describe("Favorites") {
            
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
            
            context("add to favorites", {
                it("should add translation to favorites", closure: {
                    /*
                    waitUntil(timeout: 10, action: { done in
                        storage.addTranslationToFavorites(Translations.addFavoriteTranslation, completion: { success, error in
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            
                            storage.fetchTranslation(word: Translations.addFavoriteTranslation.word, language: Translations.addFavoriteTranslation.language, translationLanguage: Translations.addFavoriteTranslation.translationLanguage, completion: { translation, error in
                                
                                expect(error).to(beNil())
                                expect(translation).toNot(beNil())
                                
                                if let translation = translation {
                                    expect(translation.word).to(equal(Translations.addFavoriteTranslation.word))
                                }
                                done()
                            })
                        })
                    })
 */
                    
                    storage.addTranslationToFavorites(Translations.addFavoriteTranslation, completion: { success, error in
                        expect(success).toEventually(beTrue())
                        expect(error).toEventually(beNil())
                        
                        storage.fetchTranslation(word: Translations.addFavoriteTranslation.word, language: Translations.addFavoriteTranslation.language, translationLanguage: Translations.addFavoriteTranslation.translationLanguage, completion: { translation, error in
                            
                            expect(error).to(beNil())
                            expect(translation).toNot(beNil())
                            
                            if let translation = translation {
                                expect(translation.word).toEventually(equal(Translations.addFavoriteTranslation.word))
                            }
                        })
                    })
                })
            })
            /*
            context("remove from favorites", {
                it("should remove translation from favorites", closure: {
                    waitUntil(timeout: 10, action: { done in
                        storage.addTranslationToFavorites(Translations.removeFavoriteTranslation, completion: { success, error in
                            
                            expect(success).to(beTrue())
                            expect(error).to(beNil())
                            
                            storage.fetchTranslation(word: Translations.removeFavoriteTranslation.word, language: Translations.removeFavoriteTranslation.language, translationLanguage: Translations.removeFavoriteTranslation.translationLanguage, completion: { translation, error in
                                
                                expect(translation).toNot(beNil())
                                expect(error).to(beNil())
                                expect(translation?.isFavorite).to(beTrue())
                                expect(translation?.word).to(equal(Translations.removeFavoriteTranslation.word))
                                
                                storage.removeTranslationFromFavorites(Translations.removeFavoriteTranslation, completion: { success, error in
                                    expect(success).to(equal(true))
                                    expect(error).to(beNil())
                                    
                                    done()
                                })
                            })
                        })
                    })
                })
            })
 */
        }
    }
}
