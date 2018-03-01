//
//  ModelsSpec.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 28/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RealmSwift
@testable import BantuDicoHistoryRealmStorage

class ModelsSpec: QuickSpec {
    
    override func spec() {
        
        describe("BDRealmTranslation") {
            
            context("Create", {
                it("should create an instance of BDRealmTranslation which is not favorite", closure: {
                    let translation = try! BDRealmTranslation(word: "hello", language: "en", translationLanguage: "fr", isFavorite: false, translations: ["salut"])
                    expect(translation.word).to(equal("hello"))
                    expect(translation.language).to(equal("en"))
                    expect(translation.translationLanguage).to(equal("fr"))
                    expect(translation.isFavorite).to(beFalse())
                    expect(translation.translations).to(equal(["salut"]))
                    expect(translation.favoriteDate).to(beNil())
                    expect(translation.saveDate).to(beNil())
                })
                
                it("should create an instance of BDRealmTranslation which is favorite", closure: {
                    let translation = try! BDRealmTranslation(word: "hello", language: "en", translationLanguage: "fr", isFavorite: true, translations: ["salut"])
                    expect(translation.word).to(equal("hello"))
                    expect(translation.language).to(equal("en"))
                    expect(translation.translationLanguage).to(equal("fr"))
                    expect(translation.isFavorite).to(beTrue())
                    expect(translation.translations).to(equal(["salut"]))
                    expect(translation.favoriteDate).toNot(beNil())
                    expect(translation.saveDate).to(beNil())
                })
            })
            
            context("Update", {
                it("should update the translation from favorite to not favorite", closure: {
                    var translation = try! BDRealmTranslation(word: "hello", language: "en", translationLanguage: "fr", isFavorite: true, translations: ["salut"])
                    translation.isFavorite = false
                    expect(translation.favoriteDate).to(beNil())
                })
            })
            
            context("Create a translations with invalid word parameters", {
                let wrongWord = ")oi,7"
                let wrongLanguage = "A32"
                let invalidTranslations: [String] = []
                it("Should throw invalid word error with word: \(wrongWord)", closure: {
                    
                    
                    expect {
                        try BDRealmTranslation(word: wrongWord, language: "en", translationLanguage: "fr", isFavorite: false, translations: ["salut"])}
                    .to(throwError { (error: Error) in
                        if case BDRealmTranslationError.invalidWord(let word) = error {
                            expect(word).to(equal(word))
                        } else {
                            fail()
                        }
                    })
                })
                
                it("Should throw invalid language error", closure: {
                    
                    expect {
                        try BDRealmTranslation(word: "hello", language: wrongLanguage, translationLanguage: "fr", isFavorite: false, translations: ["salut"]) }
                    .to(throwError { (error: Error) in
                        if case BDRealmTranslationError.invalidLanguage(let language) = error {
                            expect(language).to(equal(wrongLanguage))
                        } else {
                            fail()
                        }
                    })
                })
                
                it("Should throw invalid translations error", closure: {
                    
                    expect {
                        try BDRealmTranslation(word: "hello", language: "en", translationLanguage: "fr", isFavorite: false, translations: invalidTranslations) }
                    .to(throwError { (error: Error) in
                        if case BDRealmTranslationError.invalidTranslations(let translations) = error {
                            expect(translations).to(equal(invalidTranslations))
                        } else {
                            fail()
                        }
                    })
                })
            })
        }
    }
}

