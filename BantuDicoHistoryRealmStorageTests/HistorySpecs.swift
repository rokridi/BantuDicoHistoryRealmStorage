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
        
        AsyncDefaults.Timeout = 10
        AsyncDefaults.PollInterval = 0.1
        
        describe("Fetch history") {
            
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
                    print(error);
                }
            }
            
            context("Fetch all history", {
                it("should return one element", closure: {
                    
                    /*
                    waitUntil(timeout: 10, action: { done in
                        storage.saveTranslation(Translations.fetchTranslation, completion: { success, error in
                            expect(success).to(beTrue())
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
 */
                    
                    storage.saveTranslation(Translations.fetchTranslation, completion: { success, error in
                        expect(success).toEventually(beTrue())
                        expect(error).toEventually(beNil())
                        
                        storage.fetchAllTranslations(completion: { translations, error in
                            expect(error).toEventually(beNil())
                            expect(translations).toEventuallyNot(beNil())
                            
                            if let translations = translations {
                                
                                expect(translations.count).to(equal(1))
                                
                                if let element = translations.first {
                                    expect(element.identifier).toEventually(match(Translations.fetchTranslation.identifier))
                                }
                            }
                        })
                    })
                })
            })
            
            context("Fetch translations beginning with 'fil' history", {
                it("should return two elements", closure: {
                    /*
                    waitUntil(timeout: 10, action: {done in
                        storage.saveTranslation(Translations.filterTranslation0, completion: { success, error in
                            
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            
                            storage.saveTranslation(Translations.filterTranslation1, completion: { success, error in
                                expect(success).to(equal(true))
                                expect(error).to(beNil())
                                
                                storage.fetchAllTranslations(completion: { translations, error in
                                    expect(error).to(beNil())
                                    expect(translations).toNot(beNil())
                                    
                                    if let translations = translations {
                                        expect(translations.count).to(equal(2))
                                    }
                                    done()
                                })
                            })
                        })
                    })
 */
                    
                    storage.saveTranslation(Translations.filterTranslation0, completion: { success, error in
                        
                        expect(success).toEventually(equal(true))
                        expect(error).toEventually(beNil())
                        
                        storage.saveTranslation(Translations.filterTranslation1, completion: { success, error in
                            expect(success).toEventually(equal(true))
                            expect(error).toEventually(beNil())
                            
                            storage.fetchAllTranslations(completion: { translations, error in
                                expect(error).toEventually(beNil())
                                expect(translations).toEventuallyNot(beNil())
                                
                                if let translations = translations {
                                    expect(translations.count).toEventually(equal(2))
                                }
                            })
                        })
                    })
                })
            })
            
            context("Delete translations", {
                
                it("should delete one translation", closure: {
                    /*
                    waitUntil(timeout: 10, action: {done in
                        storage.saveTranslation(Translations.deleteTranslation0, completion: { success, error in
                            
                            expect(success).to(equal(true))
                            expect(error).to(beNil())
                            
                            storage.saveTranslation(Translations.deleteTranslation1, completion: { success, error in
                                
                                expect(success).to(equal(true))
                                expect(error).to(beNil())
                                
                                storage.fetchAllTranslations(completion: { translations, error in
                                    expect(error).to(beNil())
                                    expect(translations).toNot(beNil())
                                    expect(translations).toNot(beEmpty())
                                    
                                    storage.deleteTranslations([Translations.deleteTranslation0], completion: { success, error in
                                        expect(success).to(beTrue())
                                        expect(error).to(beNil())
                                        
                                        storage.fetchAllTranslations(completion: { translations, error in
                                            expect(error).to(beNil())
                                            expect(translations).toNot(beNil())
                                            
                                            if let translations = translations {
                                                expect(translations.count).to(equal(1))
                                            }
                                            done()
                                        })
                                    })
                                })
                            })
                        })
                    })
 */
                    
                    storage.saveTranslation(Translations.deleteTranslation0, completion: { success, error in
                        
                        expect(success).toEventually(equal(true))
                        expect(error).toEventually(beNil())
                        
                        storage.saveTranslation(Translations.deleteTranslation1, completion: { success, error in
                            
                            expect(success).toEventually(equal(true))
                            expect(error).toEventually(beNil())
                            
                            storage.fetchAllTranslations(completion: { translations, error in
                                expect(error).toEventually(beNil())
                                expect(translations).toEventuallyNot(beNil())
                                expect(translations).toEventuallyNot(beEmpty())
                                
                                storage.deleteTranslations([Translations.deleteTranslation0], completion: { success, error in
                                    expect(success).toEventually(beTrue())
                                    expect(error).toEventually(beNil())
                                    
                                    storage.fetchAllTranslations(completion: { translations, error in
                                        expect(error).toEventually(beNil())
                                        expect(translations).toEventuallyNot(beNil())
                                        
                                        if let translations = translations {
                                            expect(translations.count).toEventually(equal(1))
                                        }
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
    }
}
