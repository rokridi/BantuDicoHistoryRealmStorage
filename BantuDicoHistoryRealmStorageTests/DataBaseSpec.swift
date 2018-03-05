//
//  DataBaseSpec.swift
//  BantuDicoHistoryRealmStorageTests
//
//  Created by Mohamed Aymen Landolsi on 05/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RealmSwift
@testable import BantuDicoHistoryRealmStorage

class DataBaseSpec: QuickSpec {
    
    func writeRealm(_ realm: Realm, block: (() -> Void)) {
        
        do {
            try realm.write {
                block()
            }
        } catch let error {
            fail(error.localizedDescription)
        }
    }
    
    func realmWithMemoryIdentifier(_ identifier: String) -> Realm {
        var  configuration = Realm.Configuration()
        configuration.inMemoryIdentifier = identifier
        return try! Realm(configuration: configuration)
    }
    
    func storageWithName(_ storeName: String) -> BantuDicoHistoryRealmStorage {
        return try! BantuDicoHistoryRealmStorage(storeName: storeName, storeType: .inMemory)
    }
    
    override func spec() {
        
        describe("DataBase") {
            context("Create", {
                it("should create an instance of BDRealmTranslation which is not favorite", closure: {
                    
                    let storage = self.storageWithName("create")
                    
                    storage.saveTranslation(identifier: "helloID", word: "hello", language: "en", translationLanguage: "fr", soundURL: "https://domain.com/hello.mp3", translations: ["salut"], completion: { result in
                        expect(result.isSuccess).to(beTrue())
                        guard let value = result.value else {
                            fail()
                            return
                        }
                        expect(value.identifier).to(equal("helloID"))
                        expect(value.isFavorite).to(beFalse())
                        expect(value.favoriteDate).to(beNil())
                    })
                })
            })
            
            context("Update", {
                it("should update an instance of BDRealmTranslation", closure: {
                    
                    let storage = self.storageWithName("create")
                    let realm = self.realmWithMemoryIdentifier("create")
                    let translation = RealmTranslation(identifier: "theID", word: "the", language: "en", translationLanguage: "fr", soundURL: "https://website.com/the.mp3", isFavorite: false, translations: ["le"])
                    
                    self.writeRealm(realm, block: {
                        realm.add(translation)
                    })
                    
                    storage.saveTranslation(identifier: translation.identifier, word: translation.word, language: translation.language, translationLanguage: translation.translationLanguage, soundURL: translation.soundURL, translations: ["la", "le", "les"], completion: { result in
                        
                        guard let value = result.value else {
                            fail()
                            return
                        }
                        expect(value.translations).to(equal(["la", "le", "les"]))
                    })
                })
            })
            
            context("Fetch", {
                it("should return all translations", closure: {
                    
                    let storage = self.storageWithName("fetch")
                    let realm = self.realmWithMemoryIdentifier("fetch")
                    
                    let translation = RealmTranslation(identifier: "translationID", word: "translation", language: "en", translationLanguage: "fr", soundURL: "https://website.com/translation.mp3", isFavorite: false, translations: ["translation"])
                    let translation1 = RealmTranslation(identifier: "translation1ID", word: "translation1", language: "en", translationLanguage: "fr", soundURL: "https://website.com/translation1.mp3", isFavorite: false, translations: ["translation1"])
                    
                    self.writeRealm(realm, block: {
                        let list = List<RealmTranslation>()
                        list.append(translation)
                        list.append(translation1)
                        realm.add(list)
                    })
                    
                    storage.allTranslations(completion: { result in
                        
                        expect(result.isSuccess).to(beTrue())
                        
                        guard let translations = result.value, translations.count == 2 else {
                            fail("Invalid result.")
                            return
                        }
                        
                        expect(translations.count).to(equal(2))
                        expect(translations.first!.identifier).to(equal(translation.identifier))
                        expect(translations[1].identifier).to(equal(translation1.identifier))
                    })
                })
            })
            
            context("Favorites", {
                it("should add translation to favorites", closure: {
                    
                    let storage = self.storageWithName("addFavorite")
                    let realm = self.realmWithMemoryIdentifier("addFavorite")
                    let favorite = RealmTranslation(identifier: "favoriteID", word: "favorite", language: "en", translationLanguage: "fr", soundURL: "https://website.com/favorite.mp3", isFavorite: false, translations: ["favori"])
                    
                    self.writeRealm(realm, block: {
                        realm.add(favorite)
                    })
                    
                    storage.addRemoveFavorite(translationIdentifier: "favoriteID", isFavorite: true, completion: { result in
                        
                        expect(result.isSuccess).to(beTrue())
                        
                        guard let translation = result.value else {
                            fail("Invalid result.")
                            return
                        }
                        
                        expect(translation.isFavorite).to(beTrue())
                        expect(translation.favoriteDate).toNot(beNil())
                        expect(translation.identifier).to(equal(favorite.identifier))
                    })
                })
                
                it("should remove translation from favorites", closure: {
                    
                    let storage = self.storageWithName("removeID")
                    let realm = self.realmWithMemoryIdentifier("removeID")
                    let favorite = RealmTranslation(identifier: "removeID", word: "pain", language: "en", translationLanguage: "fr", soundURL: "https://website.com/douleur.mp3", isFavorite: true, translations: ["douleur"])
                    
                    self.writeRealm(realm, block: {
                        realm.add(favorite)
                    })
                    
                    storage.addRemoveFavorite(translationIdentifier: "removeID", isFavorite: false, completion: { result in
                        
                        expect(result.isSuccess).to(beTrue())
                        
                        guard let translation = result.value else {
                            fail("Invalid result.")
                            return
                        }
                        
                        expect(translation.isFavorite).to(beFalse())
                        expect(translation.favoriteDate).to(beNil())
                        expect(translation.identifier).to(equal(favorite.identifier))
                    })
                })
            })
        }
    }
}
