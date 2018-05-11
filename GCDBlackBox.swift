//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Max Boguslavskiy on 12/05/2018.
//  Copyright © 2018 Max Boguslavskiy. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
