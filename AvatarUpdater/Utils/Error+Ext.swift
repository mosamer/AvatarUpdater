//
//  Error+Ext.swift
//  AvatarUpdater
//
//  Created by Mostafa Amer on 25.10.17.
//  Copyright © 2017 Mostafa Amer. All rights reserved.
//

import Action

extension ActionError {
    func `is`<E: Error>(_ another: E) -> Bool where E: Equatable {
        guard case .underlyingError(let error) = self else { return false }
        guard let _error = error as? E else { return false }
        return _error == another
    }
}
