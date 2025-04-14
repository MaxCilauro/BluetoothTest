//
//  ContentView.swift
//  BluetoothPractice
//
//  Created by Yaku on 2025/04/12.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @EnvironmentObject var centralManager: CentralManager
    @EnvironmentObject var peripheralManager: PeripheralManager
    
    var body: some View {
        TabView {
            Tab("Control", systemImage: "lightbulb.circle") {
                ControlView(peripheralManager: peripheralManager)
            }

            Tab("Settings", systemImage: "gear") {
                SettingsView(centralManager: centralManager, peripheralManager: peripheralManager)
            }
        }
    }
}


#Preview {
    ContentView()
}
