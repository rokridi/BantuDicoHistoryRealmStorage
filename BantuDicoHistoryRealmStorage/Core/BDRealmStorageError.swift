//
//  BDRealmStorageError.swift
//  BantuDicoHistoryRealmStorage
//
//  Created by Mohamed Aymen Landolsi on 28/02/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

public enum BDRealmStorageError: Error {
    
    public enum DataBaseCreationFailureReason {
        case invalidStoreName(String)
    }
    
    public enum DataBaseOperationFailureReason {
        case realmAccessFailed(Error)
        case realmWriteFailed(Error)
    }
    
    case dataBaseCreationFailed(reason: DataBaseCreationFailureReason)
    case dataBaseOperationFailed(reason: DataBaseOperationFailureReason)
}

extension BDRealmStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataBaseCreationFailed(reason: _):
            return "Data base creation failed."
        case .dataBaseOperationFailed(reason: let reason):
            switch reason {
            case .realmAccessFailed(let error):
                return "Data base access failed. Error: \(error.localizedDescription)"
            case .realmWriteFailed(let error):
                return "Data base write failed. Error: \(error.localizedDescription)"
            }
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .dataBaseCreationFailed(reason: let reason):
            switch reason {
            case .invalidStoreName(let storeName):
                return "Store name is invalid: \(storeName)"
            }
        case .dataBaseOperationFailed(reason: let reason):
            switch reason {
            case .realmAccessFailed(_):
                return "Data base access failed."
            case .realmWriteFailed(_):
                return "Data base write failed."
            }
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .dataBaseCreationFailed(reason: let reason):
            switch reason {
            case .invalidStoreName(_):
                return "Store name should match pattern: [0-9a-zA-Z_]"
            }
        default:
            return nil
        }
    }
}

extension BDRealmStorageError {
    public var underlyingError: Error? {
        switch self {
        case .dataBaseCreationFailed(reason: let reason):
            return reason.underlyingError
        case .dataBaseOperationFailed(reason: let reason):
            return reason.underlyingError
        }
    }
}
extension BDRealmStorageError.DataBaseCreationFailureReason {
    public var underlyingError: Error? {
        return nil
    }
}

extension BDRealmStorageError.DataBaseOperationFailureReason {
    public var underlyingError: Error? {
        switch self {
        case .realmAccessFailed(let error):
            return error
        case .realmWriteFailed(let error):
            return error
        }
    }
}
