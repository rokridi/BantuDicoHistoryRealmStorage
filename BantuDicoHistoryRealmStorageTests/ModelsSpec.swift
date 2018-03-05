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
                    let translation = BDRealmTranslation(identifier: "helloID", word: "hello", language: "en", translationLanguage: "fr", soundURL: "https://website.com/hello.mp3", isFavorite: false, translations: ["salut"])
                    expect(translation.word).to(equal("hello"))
                    expect(translation.language).to(equal("en"))
                    expect(translation.translationLanguage).to(equal("fr"))
                    expect(translation.isFavorite).to(beFalse())
                    expect(translation.translations).to(equal(["salut"]))
                    expect(translation.favoriteDate).to(beNil())
                    expect(translation.saveDate).to(beNil())
                })
                
                it("should create an instance of BDRealmTranslation which is favorite", closure: {
                    let translation = BDRealmTranslation(identifier: "helloID", word: "hello", language: "en", translationLanguage: "fr", soundURL: "https://website.com/hello.mp3", isFavorite: true, translations: ["salut"])
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
                    var translation = BDRealmTranslation(identifier: "helloID", word: "hello", language: "en", translationLanguage: "fr", soundURL: "https://website.com/hello.mp3", isFavorite: true, translations: ["salut"])
                    translation.isFavorite = false
                    expect(translation.favoriteDate).to(beNil())
                })
            })
        }
        
        describe("RealmTranslation") {
            
            context("Create", {
                it("should create an instance of BDRealmTranslation which is not favorite", closure: {
                    let translation = RealmTranslation(identifier: "helloID", word: "hello", language: "en", translationLanguage: "fr", soundURL: "https://website.com/hello.mp3", isFavorite: false, translations: ["salut"])
                    expect(translation.word).to(equal("hello"))
                    expect(translation.language).to(equal("en"))
                    expect(translation.translationLanguage).to(equal("fr"))
                    expect(translation.isFavorite).to(beFalse())
                    expect(Array(translation.translations)).to(equal(["salut"]))
                    expect(translation.favoriteDate).to(beNil())
                })
            })
            
            context("Update", {
                it("should update the translation from favorite to not favorite", closure: {
                    let translation = RealmTranslation(identifier: "helloID", word: "hello", language: "en", translationLanguage: "fr", soundURL: "https://website.com/hello.mp3", isFavorite: false, translations: ["salut"])
                    translation.isFavorite = false
                    expect(translation.favoriteDate).to(beNil())
                })
            })
        }
    }
}

