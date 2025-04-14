//
//  BluetoothPracticeApp.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/12.
//

import SwiftUI

@main
struct BluetoothPracticeApp: App {
    @StateObject private var centralManager: CentralManager
    @StateObject private var peripheralManager: PeripheralManager
    
    init() {
        let peripheral = PeripheralManager()
        let central = CentralManager(peripheralManager: peripheral)
        
        _centralManager = StateObject(wrappedValue: central)
        _peripheralManager = StateObject(wrappedValue: peripheral)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(centralManager)
                .environmentObject(peripheralManager)
        }
    }
}
