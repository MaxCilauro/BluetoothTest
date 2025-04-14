//
//  BLE.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/14.
//

import CoreBluetooth

enum BLE {
    enum Services {
        static let ledToggle = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")
    }
    
    enum Characteristics {
        static let ledToggle = CBUUID(string: "19B10001-E8F2-537E-4F6C-D104768A1214")
    }
}
