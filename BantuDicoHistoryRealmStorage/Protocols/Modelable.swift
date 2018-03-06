//
//  Modelable.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 06/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RealmSwift

protocol Modelable {
    
    associatedtype Model: Persistable
    
    init(model: Model)
    
    func model() -> Model
}

