//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 18/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
