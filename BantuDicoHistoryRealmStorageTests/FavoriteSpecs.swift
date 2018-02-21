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
@testable import BantuDicoHistoryRealmStorage

class FavoriteSpecs: QuickSpec {
    
    let storage = BantuDicoHistoryRealmStorage(storeName: "BantuDicoHistoryRealmStorage", storeType: .inMemory)
    
    override func spec() {
        
        describe("Favorites") {
            context("add to favorites", {
                it("should add translation to favorites", closure: {
                    waitUntil(timeout: 5, action: { done in
                        let translation = BDTranslationHistory(identifier: "the-en-fr", sourceWord: "the", sourceLanguage: "en", destinationLanguage: "fr", isFavorite: false, translations: ["la", "le", "les"])
                        self.storage.addTranslationToFavorites(translation, completion: { success, error in
                            
                            self.storage.fetchFavoriteTranslations(completion: { favoriteTranslations in
                                let favorite = favoriteTranslations?.first(where: { $0.sourceWord == "the" && $0.sourceLanguage == "en" && $0.destinationLanguage == "fr" })
                                expect(success).to(equal(true))
                                expect(error).to(beNil())
                                expect(favorite).toNot(beNil())
                                done()
                            })
                        })
                    })
                })
            })
            
            context("remove from favorites", {
                
                it("should be remove translation from favorites", closure: {
                    waitUntil(timeout: 5, action: { done in
                        
                        let translation = BDTranslationHistory(identifier: "one-en-fr", sourceWord: "one", sourceLanguage: "en", destinationLanguage: "fr", isFavorite: false, translations: ["un", "une"])
                        self.storage.addTranslationToFavorites(translation, completion: { success, error in
                            
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            
                            self.storage.removeTranslationFromFavorites(translation, completion: { success, error in
                                
                                self.storage.fetchFavoriteTranslations(completion: { favoriteTranslations in
                                    let favorite = favoriteTranslations?.first(where: { $0.sourceWord == "the" && $0.sourceLanguage == "en" && $0.destinationLanguage == "fr" })
                                    expect(success).to(equal(true))
                                    expect(error).to(beNil())
                                    expect(favorite).to(beNil())
                                    done()
                                })  
                            })
                        })
                    })
                })
            })
        }
    }
}
