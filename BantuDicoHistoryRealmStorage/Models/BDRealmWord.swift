//
//  BDRealmWord.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 05/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Represents a translation of a word.
public struct BDRealmWord {
    
    /// Identifier of the translation.
    public let identifier: String
    
    /// The translated word.
    public let word: String
    
    
    /// The URL to a mp3 file representing the sound of the word.
    public let soundURL: String
    
    /// Creates an instance of BDRealmWord.
    ///
    /// - Parameters:
    ///   - identifier: identifier of word.
    ///   - word: translated word.
    ///   - soundURL: the URL to a mp3 file representing the sound of the word.
    init(identifier: String, word: String, soundURL: String) {
        self.identifier = identifier
        self.word = word
        self.soundURL = soundURL
    }
}
